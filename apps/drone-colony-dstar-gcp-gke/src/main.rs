mod app;
mod config;

use tokio::main;
use tracing::info;

#[main]
async fn main() {
    config::init_logging();
    info!("🚀 Drone Convoy Pathfinding Service Starting...");

    app::run().await;
}
