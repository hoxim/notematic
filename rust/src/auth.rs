use crate::models::*;
use crate::couchdb::CouchDbService;
use anyhow::Result;
use bcrypt::{hash, verify, DEFAULT_COST};
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    sub: String, // user_id
    exp: i64,    // expiration time
    iat: i64,    // issued at
    jti: String, // JWT ID
}

#[derive(Debug, Serialize, Deserialize)]
struct RefreshToken {
    user_id: String,
    token_id: String,
    expires_at: i64,
}

pub struct AuthService {
    couchdb: CouchDbService,
    jwt_secret: String,
    refresh_token_secret: String,
}

impl AuthService {
    pub fn new(couchdb: CouchDbService, jwt_secret: String, refresh_token_secret: String) -> Self {
        Self {
            couchdb,
            jwt_secret,
            refresh_token_secret,
        }
    }

    pub async fn register(&self, request: RegisterRequest) -> Result<AuthResponse> {
        // Check if user already exists
        if let Some(_) = self.couchdb.get_user_by_username(&request.username).await? {
            return Err(anyhow::anyhow!("Username already exists"));
        }

        // Hash password
        let password_hash = hash(request.password.as_bytes(), DEFAULT_COST)?;

        // Create user
        let user = User {
            _id: None,
            _rev: None,
            username: request.username,
            email: request.email,
            password_hash,
            created_at: Utc::now(),
            updated_at: Utc::now(),
        };

        let created_user = self.couchdb.create_user(&user).await?;

        // Generate tokens
        self.generate_tokens(&created_user._id.unwrap()).await
    }

    pub async fn login(&self, request: LoginRequest) -> Result<AuthResponse> {
        // Get user by username
        let user = self
            .couchdb
            .get_user_by_username(&request.username)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Invalid credentials"))?;

        // Verify password
        if !verify(request.password.as_bytes(), &user.password_hash)? {
            return Err(anyhow::anyhow!("Invalid credentials"));
        }

        // Generate tokens
        self.generate_tokens(&user._id.unwrap()).await
    }

    pub async fn refresh_token(&self, request: RefreshTokenRequest) -> Result<AuthResponse> {
        // Decode refresh token
        let token_data = decode::<RefreshToken>(
            &request.refresh_token,
            &DecodingKey::from_secret(self.refresh_token_secret.as_ref()),
            &Validation::default(),
        )?;

        let claims = token_data.claims;

        // Check if token is expired
        if claims.expires_at < Utc::now().timestamp() {
            return Err(anyhow::anyhow!("Refresh token expired"));
        }

        // Generate new tokens
        self.generate_tokens(&claims.user_id).await
    }

    async fn generate_tokens(&self, user_id: &str) -> Result<AuthResponse> {
        let now = Utc::now();
        let access_token_exp = now + Duration::hours(1);
        let refresh_token_exp = now + Duration::days(30);

        // Create access token claims
        let access_claims = Claims {
            sub: user_id.to_string(),
            exp: access_token_exp.timestamp(),
            iat: now.timestamp(),
            jti: Uuid::new_v4().to_string(),
        };

        // Create refresh token
        let refresh_token_id = Uuid::new_v4().to_string();
        let refresh_token_claims = RefreshToken {
            user_id: user_id.to_string(),
            token_id: refresh_token_id.clone(),
            expires_at: refresh_token_exp.timestamp(),
        };

        // Encode tokens
        let access_token = encode(
            &Header::default(),
            &access_claims,
            &EncodingKey::from_secret(self.jwt_secret.as_ref()),
        )?;

        let refresh_token = encode(
            &Header::default(),
            &refresh_token_claims,
            &EncodingKey::from_secret(self.refresh_token_secret.as_ref()),
        )?;

        Ok(AuthResponse {
            access_token,
            refresh_token,
            token_type: "Bearer".to_string(),
            expires_in: 3600, // 1 hour
        })
    }

    pub fn verify_token(&self, token: &str) -> Result<String> {
        let token_data = decode::<Claims>(
            token,
            &DecodingKey::from_secret(self.jwt_secret.as_ref()),
            &Validation::default(),
        )?;

        Ok(token_data.claims.sub)
    }
} 