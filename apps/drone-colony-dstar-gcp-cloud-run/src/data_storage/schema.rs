use serde::{Serialize, Deserialize};

/// Represents a Firestore Drone document.
#[derive(Debug, Serialize, Deserialize)]
pub struct Drone {
    pub id: String, // Firestore uses STRING for IDs
    pub status: String,
    pub last_known_latitude: Option<f64>,
    pub last_known_longitude: Option<f64>,
    pub last_update: Option<String>, // Firestore stores TIMESTAMP as RFC3339 string
}

/// Represents a Waypoint document.
#[derive(Debug, Serialize, Deserialize)]
pub struct Waypoint {
    pub drone_id: String,
    pub latitude: f64,
    pub longitude: f64,
    pub timestamp: String,
}

/// Represents a Sortie document.
#[derive(Debug, Serialize, Deserialize)]
pub struct Sortie {
    pub drone_id: String,
    pub status: String,
    pub start_time: String,
    pub end_time: Option<String>,
}
