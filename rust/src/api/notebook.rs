use crate::models::*;
use crate::config::Config;
use anyhow::Result;
use reqwest::Client;

static mut API_CLIENT: Option<Client> = None;
static mut CONFIG: Option<Config> = None;

#[flutter_rust_bridge::frb]
pub async fn create_notebook(access_token: String, name: String, description: Option<String>, color: Option<String>) -> Result<Notebook, String> {
    let request = CreateNotebookRequest {
        name,
        description,
        color,
    };
    
    unsafe {
        if let Some(client) = &API_CLIENT {
            let api_base_url = CONFIG.as_ref().map(|c| c.api_base_url.clone()).unwrap_or_else(|| "http://127.0.0.1:8080".to_string());
            let url = format!("{}/protected/notebooks", api_base_url);
            let response = client
                .post(&url)
                .header("Authorization", &format!("Bearer {}", access_token))
                .json(&request)
                .send()
                .await
                .map_err(|e| e.to_string())?;
            
            if response.status().is_success() {
                let notebook: Notebook = response.json().await.map_err(|e| e.to_string())?;
                Ok(notebook)
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
pub async fn get_user_notebooks(access_token: String) -> Result<Vec<Notebook>, String> {
    unsafe {
        if let Some(client) = &API_CLIENT {
            let api_base_url = CONFIG.as_ref().map(|c| c.api_base_url.clone()).unwrap_or_else(|| "http://127.0.0.1:8080".to_string());
            let url = format!("{}/protected/notebooks", api_base_url);
            let response = client
                .get(&url)
                .header("Authorization", &format!("Bearer {}", access_token))
                .send()
                .await
                .map_err(|e| e.to_string())?;
            
            if response.status().is_success() {
                let notebooks: Vec<Notebook> = response.json().await.map_err(|e| e.to_string())?;
                Ok(notebooks)
            } else {
                let error: ApiError = response.json().await.map_err(|e| e.to_string())?;
                Err(error.error)
            }
        } else {
            Err("API client not initialized".to_string())
        }
    }
} 