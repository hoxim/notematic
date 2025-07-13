use std::env;

pub struct Config {
    pub api_base_url: String,
    pub api_host: String,
    pub api_port: u16,
    pub couchdb_url: String,
    pub couchdb_user: String,
    pub couchdb_password: String,
    pub jwt_secret: String,
    pub environment: String,
}

impl Config {
    pub fn new() -> Self {
        let api_host = env::var("API_HOST").unwrap_or_else(|_| "127.0.0.1".to_string());
        let api_port = env::var("API_PORT")
            .unwrap_or_else(|_| "8080".to_string())
            .parse::<u16>()
            .unwrap_or(8080);
        let api_base_url = format!("http://{}:{}", api_host, api_port);

        let couchdb_url = env::var("COUCHDB_URL").unwrap_or_else(|_| "http://192.168.50.90:5984".to_string());
        let couchdb_user = env::var("COUCHDB_USER").unwrap_or_else(|_| "hoxim".to_string());
        let couchdb_password = env::var("COUCHDB_PASSWORD").unwrap_or_else(|_| "your_secure_password".to_string());
        
        let jwt_secret = env::var("JWT_SECRET").unwrap_or_else(|_| "your_super_secure_jwt_secret_key_here".to_string());
        let environment = env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string());

        Self {
            api_base_url,
            api_host,
            api_port,
            couchdb_url,
            couchdb_user,
            couchdb_password,
            jwt_secret,
            environment,
        }
    }

    pub fn is_development(&self) -> bool {
        self.environment == "development"
    }

    pub fn is_production(&self) -> bool {
        self.environment == "production"
    }

    pub fn log_configuration(&self) {
        println!("=== Rust Config ===");
        println!("Environment: {}", self.environment);
        println!("API Base URL: {}", self.api_base_url);
        println!("CouchDB URL: {}", self.couchdb_url);
        println!("CouchDB User: {}", self.couchdb_user);
        println!("Is Development: {}", self.is_development());
        println!("Is Production: {}", self.is_production());
        println!("==================");
    }
}

impl Default for Config {
    fn default() -> Self {
        Self::new()
    }
} 