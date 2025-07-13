use crate::models::*;
use crate::config::Config;
use anyhow::Result;
use reqwest::Client;

static mut API_CLIENT: Option<Client> = None;
static mut CONFIG: Option<Config> = None;

#[flutter_rust_bridge::frb]
pub async fn create_note(access_token: String, notebook_id: String, title: String, content: String) -> Result<Note, String> {
    let request = CreateNoteRequest {
        notebook_id,
        title,
        content,
    };
    
    unsafe {
        if let Some(client) = &API_CLIENT {
            let api_base_url = CONFIG.as_ref().map(|c| c.api_base_url.clone()).unwrap_or_else(|| "http://127.0.0.1:8080".to_string());
            let url = format!("{}/protected/notes", api_base_url);
            let response = client
                .post(&url)
                .header("Authorization", &format!("Bearer {}", access_token))
                .json(&request)
                .send()
                .await
                .map_err(|e| e.to_string())?;
            
            if response.status().is_success() {
                let note: Note = response.json().await.map_err(|e| e.to_string())?;
                Ok(note)
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
pub async fn get_notebook_notes(notebook_id: String) -> Result<Vec<Note>, String> {
    unsafe {
        if let Some(client) = &API_CLIENT {
            let api_base_url = CONFIG.as_ref().map(|c| c.api_base_url.clone()).unwrap_or_else(|| "http://127.0.0.1:8080".to_string());
            let url = format!("{}/protected/notebooks/{}/notes", api_base_url, notebook_id);
            let response = client
                .get(&url)
                .send()
                .await
                .map_err(|e| e.to_string())?;
            
            if response.status().is_success() {
                let notes: Vec<Note> = response.json().await.map_err(|e| e.to_string())?;
                Ok(notes)
            } else {
                let error: ApiError = response.json().await.map_err(|e| e.to_string())?;
                Err(error.error)
            }
        } else {
            Err("API client not initialized".to_string())
        }
    }
} 