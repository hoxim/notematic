use crate::models::*;
use anyhow::Result;
use reqwest::Client;
use serde_json::Value;

#[derive(Clone)]
pub struct CouchDbService {
    client: Client,
    base_url: String,
    username: String,
    password: String,
}

impl CouchDbService {
    pub fn new(base_url: String, username: String, password: String) -> Self {
        Self {
            client: Client::new(),
            base_url,
            username,
            password,
        }
    }

    async fn make_request(
        &self,
        method: reqwest::Method,
        path: &str,
        body: Option<Value>,
    ) -> Result<reqwest::Response> {
        let url = format!("{}{}", self.base_url, path);
        let mut request = self.client.request(method, &url);
        
        request = request.basic_auth(&self.username, Some(&self.password));
        
        if let Some(body) = body {
            request = request.json(&body);
        }
        
        let response = request.send().await?;
        Ok(response)
    }

    pub async fn create_user(&self, user: &User) -> Result<User> {
        let response = self
            .make_request(
                reqwest::Method::POST,
                "/users",
                Some(serde_json::to_value(user)?),
            )
            .await?;

        if response.status().is_success() {
            let created_user: CouchDbResponse<User> = response.json().await?;
            Ok(created_user.data)
        } else {
            let error: ApiError = response.json().await?;
            Err(anyhow::anyhow!("Failed to create user: {}", error.error))
        }
    }

    pub async fn get_user_by_username(&self, username: &str) -> Result<Option<User>> {
        let response = self
            .make_request(
                reqwest::Method::GET,
                &format!("/users/_design/users/_view/by_username?key=\"{}\"", username),
                None,
            )
            .await?;

        if response.status().is_success() {
            let view_response: CouchDbViewResponse<User> = response.json().await?;
            Ok(view_response.rows.into_iter().next().map(|row| row.doc.unwrap()))
        } else {
            Ok(None)
        }
    }

    pub async fn create_notebook(&self, notebook: &Notebook) -> Result<Notebook> {
        let response = self
            .make_request(
                reqwest::Method::POST,
                "/notebooks",
                Some(serde_json::to_value(notebook)?),
            )
            .await?;

        if response.status().is_success() {
            let created_notebook: CouchDbResponse<Notebook> = response.json().await?;
            Ok(created_notebook.data)
        } else {
            let error: ApiError = response.json().await?;
            Err(anyhow::anyhow!("Failed to create notebook: {}", error.error))
        }
    }

    pub async fn get_user_notebooks(&self, user_id: &str) -> Result<Vec<Notebook>> {
        let response = self
            .make_request(
                reqwest::Method::GET,
                &format!("/notebooks/_design/notebooks/_view/by_user?key=\"{}\"", user_id),
                None,
            )
            .await?;

        if response.status().is_success() {
            let view_response: CouchDbViewResponse<Notebook> = response.json().await?;
            Ok(view_response
                .rows
                .into_iter()
                .filter_map(|row| row.doc)
                .collect())
        } else {
            Err(anyhow::anyhow!("Failed to get user notebooks"))
        }
    }

    pub async fn create_note(&self, note: &Note) -> Result<Note> {
        let response = self
            .make_request(
                reqwest::Method::POST,
                "/notes",
                Some(serde_json::to_value(note)?),
            )
            .await?;

        if response.status().is_success() {
            let created_note: CouchDbResponse<Note> = response.json().await?;
            Ok(created_note.data)
        } else {
            let error: ApiError = response.json().await?;
            Err(anyhow::anyhow!("Failed to create note: {}", error.error))
        }
    }

    pub async fn get_notebook_notes(&self, notebook_id: &str) -> Result<Vec<Note>> {
        let response = self
            .make_request(
                reqwest::Method::GET,
                &format!("/notes/_design/notes/_view/by_notebook?key=\"{}\"", notebook_id),
                None,
            )
            .await?;

        if response.status().is_success() {
            let view_response: CouchDbViewResponse<Note> = response.json().await?;
            Ok(view_response
                .rows
                .into_iter()
                .filter_map(|row| row.doc)
                .collect())
        } else {
            Err(anyhow::anyhow!("Failed to get notebook notes"))
        }
    }
} 