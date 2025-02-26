use firebase_admin::firestore::{FirestoreDb, Document};
use crate::data_storage::schema::{Drone, Waypoint, Sortie};
use tracing::{info, error};
use serde_json::json;

/// Firestore Database Client
pub struct FirestoreClient {
    db: FirestoreDb,
}

impl FirestoreClient {
    /// Initializes Firestore Connection
    pub async fn new() -> Self {
        let db = FirestoreDb::new("xxxx-gcp-project-id").await.unwrap();
        FirestoreClient { db }
    }

    /// Inserts or updates a Drone's status.
    pub async fn update_drone_status(&self, drone: &Drone) {
        let collection = self.db.collection("drones");
        match collection.document(&drone.id).set(drone).await {
            Ok(_) => info!("Drone {} status updated.", drone.id),
            Err(e) => error!("Failed to update drone {}: {:?}", drone.id, e),
        }
    }

    /// Records a waypoint.
    pub async fn record_waypoint(&self, waypoint: &Waypoint) {
        let collection = self.db.collection("waypoints");
        match collection.add(&json!(waypoint)).await {
            Ok(_) => info!("Waypoint recorded for drone {}", waypoint.drone_id),
            Err(e) => error!("Failed to record waypoint: {:?}", e),
        }
    }

    /// Starts a new sortie.
    pub async fn start_sortie(&self, sortie: &Sortie) {
        let collection = self.db.collection("sorties");
        match collection.add(&json!(sortie)).await {
            Ok(_) => info!("Sortie started for drone {}", sortie.drone_id),
            Err(e) => error!("Failed to start sortie: {:?}", e),
        }
    }
}
