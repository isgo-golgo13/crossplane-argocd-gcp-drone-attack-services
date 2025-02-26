use google_cloud_spanner::client::{Client, ClientConfig};
use google_cloud_spanner::SessionConfig;
use tracing::info;

pub async fn update_drone_status(drone_id: &str, latitude: f64, longitude: f64) {
    let client = Client::new(ClientConfig {
        instance_id: "spanner-instance".to_string(),
        database_id: "drone_tracking".to_string(),
        session_config: SessionConfig::default(),
    }).await.unwrap();

    let sql = "UPDATE drones SET latitude = @lat, longitude = @long WHERE id = @id";
    let params = [("lat", latitude.into()), ("long", longitude.into()), ("id", drone_id.into())];

    client.execute_sql(sql, &params).await.unwrap();
    info!("Updated {} position in Spanner.", drone_id);
}
