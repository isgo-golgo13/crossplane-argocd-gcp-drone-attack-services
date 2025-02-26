use tokio::time::{self, Duration};
use tracing::info;
use crate::drones::simulation::simulate_drones;

pub async fn run() {
    let mut interval = time::interval(Duration::from_secs(10));
    loop {
        interval.tick().await;
        info!("Starting drone simulation step...");
        simulate_drones().await;
    }
}
