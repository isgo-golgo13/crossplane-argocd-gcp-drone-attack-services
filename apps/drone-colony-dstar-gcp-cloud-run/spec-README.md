## Drone Colony Double A*Star Pathfinding Drone Sortie App (GCP CloudRun)

## Database Schema (GCP Firestore)

- `drones/{drone_id}` (Root Collection)
    - `status: ACTIVE | INACTIVE | DESTROYED`
    - `last_known_latitude: FLOAT`
    - `last_known_longitude: FLOAT`
    - `last_update: TIMESTAMP`

- `waypoints/{waypoint_id}` (Collection in Each Drone)
    - `drone_id: STRING`
    - `latitude: FLOAT`
    - `longitude: FLOAT`
    - `timestamp: TIMESTAMP`

- `sorties/{sortie_id}` (Root Collection)
    - `drone_id: STRING`
    - `status: ONGOING | COMPLETED | FAILED`
    - `start_time: TIMESTAMP`
    - `end_time: TIMESTAMP`