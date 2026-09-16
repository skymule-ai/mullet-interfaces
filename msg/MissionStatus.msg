# Status snapshot of one mission framework on one drone.
#
# Published by every mission framework node on /mullet/mission_status at 2 Hz. Every message
# is a complete snapshot. Consumers discover the frameworks a drone offers from this topic
# alone, the same way they discover drones from /mullet/heartbeat.

builtin_interfaces/Time stamp
string drone_id            # Matches DroneHeartbeat.drone_id.
string framework           # e.g. "ergodic".
string spec_schema         # Spec format load_service_path accepts, e.g. "ergodic/1".
string load_service_path   # Fully-qualified mullet_interfaces/srv/LoadMission service.
string list_service_path   # Fully-qualified mullet_interfaces/srv/ListMissions service.

# --- Mission ------------------------------------------------------------------------------
# Labels: SELF_TEST (checking itself after boot), EMPTY (nothing loaded), PREPARING
# (preflight running), READY (safe to start_mission), RUNNING (streaming commands in
# MISSION), PAUSED (loaded and started, FSM left MISSION), DONE (finished, drone held),
# FAULT (refused to run; detail and preflight say why).
string mission_id          # Empty when nothing is loaded.
string state_label
string detail              # Human-readable reason or progress note.
float32 progress           # Fraction of the mission completed, 0.0 to 1.0.

# --- Preflight ----------------------------------------------------------------------------
# One entry per check in run order: "<check>: ok" or "<check>: FAIL <reason>".
string[] preflight
string device              # Compute device the mission runs on ("gpu", "cpu"), or empty.
float32 step_ms_p99        # Measured 99th-percentile controller step time, milliseconds.
