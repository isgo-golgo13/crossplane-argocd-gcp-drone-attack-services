use crate::drones::drone::Drone;
use crate::pathfinding::dstar::Position;
use tracing::{info, error};

/// Represents an attack sortie for drones.
pub struct AttackSortie {
    pub drones: Vec<Drone>,
    pub target: Position,
}

impl AttackSortie {
    pub fn new(drones: Vec<Drone>, target: Position) -> Self {
        AttackSortie { drones, target }
    }

    /// Executes the sortie.
    pub fn execute(&mut self) {
        info!("Starting attack sortie!");

        for drone in &mut self.drones {
            let path = drone.plan_path(self.target);
            if path.is_empty() {
                error!("Drone {} failed to find a path!", drone.id);
                continue;
            }

            for step in path {
                drone.move_to(step);
            }

            info!("Drone {} reached the target!", drone.id);
        }
    }
}
