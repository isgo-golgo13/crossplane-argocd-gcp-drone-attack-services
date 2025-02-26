use axum::{routing::post, Router, Json};
use serde::{Deserialize, Serialize};
use crate::data_storage::api;
use std::net::SocketAddr;
use tracing::{info, error};

/// Request payload to update drone status.
#[derive(Debug, Deserialize)]
struct DroneUpdateRequest {
    drone_id: String,
    latitude: f64,
    longitude: f64,
}

/// API response format.
#[derive(Debug, Serialize)]
struct ApiResponse {
    message: String,
}

/// Updates a drone's status.
async fn update_drone(Json(payload): Json<DroneUpdateRequest>) -> Json<ApiResponse> {
    info!("📡 Received update for Drone {}", payload.drone_id);
    api::update_drone_status(&payload.drone_id, payload.latitude, payload.longitude).await;
    Json(ApiResponse {
        message: format!("Drone {} position updated", payload.drone_id),
    })
}

/// Registers Axum routes.
pub fn create_router() -> Router {
    Router::new().route("/update-drone", post(update_drone))
}
