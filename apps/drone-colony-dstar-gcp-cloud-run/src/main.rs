use axum::Server;
use tokio::net::TcpListener;
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;
use crate::app::create_router;

mod app;
mod data_storage;
mod drones;
mod pathfinding;

#[tokio::main]
async fn main() {
    // Initialize logging
    let subscriber = FmtSubscriber::builder().with_max_level(Level::INFO).finish();
    tracing::subscriber::set_global_default(subscriber).expect("Failed to set global subscriber");

    info!("Starting Drone AI Cloud Run Service...");

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080)); // Cloud Run listens on 8080
    let router = create_router();

    let listener = TcpListener::bind(addr).await.expect("⚠️ Failed to bind address");
    Server::from_tcp(listener).unwrap().serve(router.into_make_service()).await.unwrap();
}
