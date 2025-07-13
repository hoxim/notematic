use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Note {
    pub _id: Option<String>,
    pub _rev: Option<String>,
    pub user_id: String,
    pub notebook_id: String,
    pub title: String,
    pub content: String,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateNoteRequest {
    pub notebook_id: String,
    pub title: String,
    pub content: String,
} 