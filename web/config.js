// Notematic App Configuration
// This file is used only on web (in browser)
window.APP_CONFIG = {
  // API Configuration
  API_HOST: 'twoj-serwer.pl', // Change to your server address
  API_PORT: 8080,
  
  // Environment
  ENVIRONMENT: 'production', // 'development' or 'production'
  
  // CouchDB Configuration (for reference)
  COUCHDB_URL: 'http://192.168.50.90:5984',
  COUCHDB_USER: 'hoxim',
  COUCHDB_PASSWORD: 'your_secure_password',
  
  // JWT Configuration (for reference)
  JWT_SECRET: 'your_super_secure_jwt_secret_key_here'
};

// Function to get configuration
window.getAppConfig = function(key, defaultValue = null) {
  return window.APP_CONFIG[key] || defaultValue;
};

// Function to check environment
window.isDevelopment = function() {
  return window.APP_CONFIG.ENVIRONMENT === 'development';
};

window.isProduction = function() {
  return window.APP_CONFIG.ENVIRONMENT === 'production';
}; 