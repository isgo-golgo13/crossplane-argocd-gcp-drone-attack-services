use crate::pathfinding::dstar::{DStarPathfinder, Position};
use tracing::{info, error};

/// Represents a drone in the simulation.
pub struct Drone {
    pub id: String,
    pub position: Position,
    pub status: String,
    pub pathfinder: DStarPathfinder,
}

impl Drone {
    pub fn new(id: &str, start_position: Position) -> Self {
        Drone {
            id: id.to_string(),
            position: start_position,
            status: "ACTIVE".to_string(),
            pathfinder: DStarPathfinder::new(),
        }
    }

    /// Moves the drone to a new position.
    pub fn move_to(&mut self, target: Position) {
        self.position = target;
        info!("🚀 Drone {} moved to position {:?}", self.id, self.position);
    }

    /// Plans a path using D*.
    pub fn plan_path(&self, goal: Position) -> Vec<Position> {
        self.pathfinder.find_path(self.position, goal)
    }
}
