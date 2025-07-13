use crate::models::*;
use anyhow::Result;
use reqwest::Client;
use jsonwebtoken::{decode, DecodingKey, Validation};
use serde::{Deserialize, Serialize};

use crate::config::Config;

static mut API_CLIENT: Option<Client> = None;
static mut CONFIG: Option<Config> = None;

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    sub: String, // user_id
    exp: i64,    // expiration time
    iat: i64,    // issued at
    jti: String, // JWT ID
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
    
    // Initialize HTTP client and config
    unsafe {
        API_CLIENT = Some(Client::new());
        CONFIG = Some(Config::new());
        
        if let Some(config) = &CONFIG {
            config.log_configuration();
        }
    }
}

#[flutter_rust_bridge::frb]
pub async fn register_user(username: String, email: String, password: String) -> Result<AuthResponse, String> {
    let request = RegisterRequest {
        username,
        email,
        password,
    };
    
    unsafe {
        if let Some(client) = &API_CLIENT {
            let api_base_url = CONFIG.as_ref().map(|c| c.api_base_url.clone()).unwrap_or_else(|| "http://127.0.0.1:8080".to_string());
            let url = format!("{}/auth/register", api_base_url);
            let response = client
                .post(&url)
                .json(&request)
                .send()
                .await
                .map_err(|e| e.to_string())?;
            
            if response.status().is_success() {
                let auth_response: AuthResponse = response.json().await.map_err(|e| e.to_string())?;
                Ok(auth_response)
            } else {
                let error: ApiError = response.json().await.map_err(|e| e.to_string())?;
                Err(error.error)
            }
        } else {
            Err("API client not initialized".to_string())
        }
    }
}

#[flutter_rust_bridge::frb]
pub async fn login_user(username: String, password: String) -> Result<AuthResponse, String> {
    let request = LoginRequest {
        username,
        password,
    };
    
    unsafe {
        if let Some(client) = &API_CLIENT {
            let api_base_url = CONFIG.as_ref().map(|c| c.api_base_url.clone()).unwrap_or_else(|| "http://127.0.0.1:8080".to_string());
            let url = format!("{}/auth/login", api_base_url);
            let response = client
                .post(&url)
                .json(&request)
                .send()
                .await
                .map_err(|e| e.to_string())?;
            
            if response.status().is_success() {
                let auth_response: AuthResponse = response.json().await.map_err(|e| e.to_string())?;
                Ok(auth_response)
            } else {
                let error: ApiError = response.json().await.map_err(|e| e.to_string())?;
                Err(error.error)
            }
        } else {
            Err("API client not initialized".to_string())
        }
    }
}

#[flutter_rust_bridge::frb]
pub async fn refresh_user_token(refresh_token: String) -> Result<AuthResponse, String> {
    let request = RefreshTokenRequest {
        refresh_token,
    };
    
    unsafe {
        if let Some(client) = &API_CLIENT {
            let api_base_url = CONFIG.as_ref().map(|c| c.api_base_url.clone()).unwrap_or_else(|| "http://127.0.0.1:8080".to_string());
            let url = format!("{}/auth/refresh", api_base_url);
            let response = client
                .post(&url)
                .json(&request)
                .send()
                .await
                .map_err(|e| e.to_string())?;
            
            if response.status().is_success() {
                let auth_response: AuthResponse = response.json().await.map_err(|e| e.to_string())?;
                Ok(auth_response)
            } else {
                let error: ApiError = response.json().await.map_err(|e| e.to_string())?;
                Err(error.error)
            }
        } else {
            Err("API client not initialized".to_string())
        }
    }
}

fn decode_token(token: &str) -> Result<String, String> {
    unsafe {
        let jwt_secret = CONFIG.as_ref().map(|c| c.jwt_secret.clone()).unwrap_or_else(|| "your_super_secure_jwt_secret_key_here".to_string());
        let key = DecodingKey::from_secret(jwt_secret.as_ref());
    let validation = Validation::default();
    
    match decode::<Claims>(token, &key, &validation) {
        Ok(token_data) => Ok(token_data.claims.sub),
        Err(_) => Err("Invalid token".to_string()),
        }
    }
}

pub fn greet(name: String) -> String {
    format!("Hello, {}!", name)
} 