use std::collections::{BinaryHeap, HashMap};
use std::cmp::Ordering;
use rand::Rng;
use tracing::{info, debug};

/// Represents a point in the grid.
#[derive(Copy, Clone, Eq, PartialEq, Hash, Debug)]
pub struct Node {
    pub x: i32,
    pub y: i32,
}

/// Represents a state in the priority queue.
#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    cost: i32,
    node: Node,
}

/// Custom ordering for the priority queue (min-heap).
impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        other.cost.cmp(&self.cost)
            .then_with(|| self.node.x.cmp(&other.node.x))
            .then_with(|| self.node.y.cmp(&other.node.y))
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

/// A* pathfinding with Ant Colony heuristic influence.
pub fn double_astar_find_path(
    start: Node,
    goal: Node,
    grid: &Vec<Vec<u8>>,
    pheromones: &mut HashMap<Node, f64>,
) -> Vec<Node> {
    let mut open_set = BinaryHeap::new();
    let mut came_from: HashMap<Node, Node> = HashMap::new();
    let mut g_score: HashMap<Node, f64> = HashMap::new();
    let mut f_score: HashMap<Node, f64> = HashMap::new();
    
    g_score.insert(start, 0.0);
    f_score.insert(start, heuristic(start, goal) as f64);

    open_set.push(State { cost: 0, node: start });

    while let Some(State { node, cost }) = open_set.pop() {
        if node == goal {
            info!("🎯 Path found for drone.");
            return reconstruct_path(came_from, node);
        }

        for neighbor in get_neighbors(node, grid) {
            let tentative_g_score = g_score.get(&node).unwrap_or(&f64::INFINITY) + 1.0;
            let pheromone_bonus = pheromones.get(&neighbor).unwrap_or(&0.0) * 5.0; // 🐜 Ant Colony boost
            let new_cost = tentative_g_score - pheromone_bonus;

            if new_cost < *g_score.get(&neighbor).unwrap_or(&f64::INFINITY) {
                came_from.insert(neighbor, node);
                g_score.insert(neighbor, new_cost);
                f_score.insert(neighbor, new_cost + heuristic(neighbor, goal) as f64);
                open_set.push(State { cost: f_score[&neighbor] as i32, node: neighbor });
            }
        }
    }

    debug!("⚠️ No path found for drone.");
    vec![] // No path found
}

/// Manhattan distance heuristic for A*.
fn heuristic(node: Node, goal: Node) -> i32 {
    (node.x - goal.x).abs() + (node.y - goal.y).abs()
}

/// Returns neighboring nodes in a 4-way grid system.
fn get_neighbors(node: Node, grid: &Vec<Vec<u8>>) -> Vec<Node> {
    let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)];
    let mut neighbors = vec![];

    for (dx, dy) in directions.iter() {
        let new_x = node.x + dx;
        let new_y = node.y + dy;

        if new_x >= 0 && new_x < grid.len() as i32 && new_y >= 0 && new_y < grid[0].len() as i32 {
            if grid[new_x as usize][new_y as usize] == 0 {
                neighbors.push(Node { x: new_x, y: new_y });
            }
        }
    }
    neighbors
}

/// Reconstructs the path after A* completion.
fn reconstruct_path(mut came_from: HashMap<Node, Node>, mut current: Node) -> Vec<Node> {
    let mut path = vec![current];

    while let Some(prev) = came_from.remove(&current) {
        path.push(prev);
        current = prev;
    }
    
    path.reverse();
    path
}

/// Updates pheromone levels based on successful paths (Ant Colony Optimization).
pub fn update_pheromones(pheromones: &mut HashMap<Node, f64>, path: &Vec<Node>, decay_factor: f64) {
    for node in path {
        let entry = pheromones.entry(*node).or_insert(0.0);
        *entry += 1.0;
    }

    for (_, pheromone) in pheromones.iter_mut() {
        *pheromone *= decay_factor;
    }
}
