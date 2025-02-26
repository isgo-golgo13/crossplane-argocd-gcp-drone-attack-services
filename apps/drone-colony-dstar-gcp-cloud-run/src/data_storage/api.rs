use crate::data_storage::firestore_client::FirestoreClient;
use crate::data_storage::schema::{Drone, Waypoint, Sortie};
use tracing::{info, error};

/// Fetches or updates drone status in Firestore.
pub async fn update_drone_status(drone_id: &str, latitude: f64, longitude: f64) {
    let firestore = FirestoreClient::new().await;
    let drone = Drone {
        id: drone_id.to_string(),
        status: "ACTIVE".to_string(),
        last_known_latitude: Some(latitude),
        last_known_longitude: Some(longitude),
        last_update: Some(chrono::Utc::now().to_rfc3339()),
    };

    firestore.update_drone_status(&drone).await;
}

/// Records a drone reaching a waypoint.
pub async fn record_waypoint(drone_id: &str, latitude: f64, longitude: f64) {
    let firestore = FirestoreClient::new().await;
    let waypoint = Waypoint {
        drone_id: drone_id.to_string(),
        latitude,
        longitude,
        timestamp: chrono::Utc::now().to_rfc3339(),
    };

    firestore.record_waypoint(&waypoint).await;
}

/// Starts a new sortie for a drone.
pub async fn start_sortie(drone_id: &str) {
    let firestore = FirestoreClient::new().await;
    let sortie = Sortie {
        drone_id: drone_id.to_string(),
        status: "ONGOING".to_string(),
        start_time: chrono::Utc::now().to_rfc3339(),
        end_time: None,
    };

    firestore.start_sortie(&sortie).await;
}
