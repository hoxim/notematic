use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Notebook {
    pub _id: Option<String>,
    pub _rev: Option<String>,
    pub user_id: String,
    pub name: String,
    pub description: Option<String>,
    pub color: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateNotebookRequest {
    pub name: String,
    pub description: Option<String>,
    pub color: Option<String>,
} 