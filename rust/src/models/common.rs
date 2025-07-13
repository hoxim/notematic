use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct ApiError {
    pub error: String,
    pub status_code: Option<u16>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CouchDbResponse<T> {
    pub _id: String,
    pub _rev: String,
    #[serde(flatten)]
    pub data: T,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CouchDbViewResponse<T> {
    pub total_rows: i64,
    pub offset: i64,
    pub rows: Vec<CouchDbViewRow<T>>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CouchDbViewRow<T> {
    pub id: String,
    pub key: String,
    pub value: T,
    pub doc: Option<T>,
} 