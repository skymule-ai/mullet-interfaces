# Operator-facing status snapshot for one Mullet drone.
#
# Published by mullet_core on /mullet/heartbeat at heartbeat_rate_hz (10 Hz by default).
# Every message is a complete snapshot: nothing is incremental, and a consumer that misses
# a message loses nothing but latency. Consumers discover drones from this topic alone.

# --- Envelope -------------------------------------------------------------------------
uint32 schema_version    # Currently 3. mullet_core bumps it on any change to this file.
builtin_interfaces/Time stamp
uint64 sequence          # Monotonic per publisher; gaps mean dropped samples.

# --- Identity -------------------------------------------------------------------------
string drone_id
uint8 vehicle_instance   # PX4 instance index. 0 is the unprefixed single-vehicle case.
uint8 target_system      # MAVLink system id: vehicle_instance + 1.
string ros_namespace     # Namespace the node runs in; the paths below are joined onto it.
string px4_fmu_prefix    # Topic prefix for this instance's /fmu/... topics.

# --- Command paths --------------------------------------------------------------------
# Fully-qualified names, so a client never has to rebuild them from the namespace itself.
string takeoff_action_path       # mullet_interfaces/action/Takeoff
string land_action_path          # mullet_interfaces/action/Land
string return_home_action_path   # mullet_interfaces/action/ReturnHome
string start_mission_service_path  # std_srvs/srv/Trigger: HOLD -> MISSION
string hold_service_path         # std_srvs/srv/Trigger: MISSION or return_home -> HOLD

# --- Supervisor state -----------------------------------------------------------------
# Labels are IDLE, TRANSITION, HOLD, MISSION. The numeric fields are the DroneState enum
# ordinal and are not a stable contract; the labels are. Sequencing inside TRANSITION stays
# inside the drone; active_action says which transition is running.
uint16 state
string state_label
uint16 previous_state
string previous_state_label
string active_action     # "takeoff", "land" or "return_home" while TRANSITION, else empty.

# --- Data availability ----------------------------------------------------------------
# Whether the supervisor has ever received each input. Answers "is this field meaningful",
# not "is the vehicle healthy".
bool has_vehicle_status
bool has_local_position
bool has_land_detected
bool has_command_stream  # A valid MissionCommand has been received at some point.

# --- Vehicle condition ----------------------------------------------------------------
bool armed
bool offboard
bool px4_failsafe        # Mirrors PX4 VehicleStatus.failsafe. Observability only.
bool landed
bool local_position_valid
bool command_stream_valid  # The latest MissionCommand is still within its timeout.
                           # False in MISSION means the drone is holding its last position.

# --- PX4 status -----------------------------------------------------------------------
# Raw PX4 VehicleStatus enum values with decoded labels. Labels read UNKNOWN until the
# first VehicleStatus arrives.
uint8 px4_nav_state
string px4_nav_state_label
uint8 px4_arming_state
string px4_arming_state_label

# --- Local position -------------------------------------------------------------------
# PX4 local NED frame: metres, z positive down, yaw in radians clockwise from north. All
# zero unless local_position_valid. Each drone has its own local origin: compare drones
# through the global position below, never through x/y.
float64 x
float64 y
float64 z
float64 yaw

# --- Global position ------------------------------------------------------------------
# WGS84, derived from the local position and PX4's EKF origin. All zero unless
# global_position_valid.
bool global_position_valid
float64 lat              # Degrees.
float64 lon              # Degrees.
float64 alt              # Metres above mean sea level.

# --- Capability flags -----------------------------------------------------------------
# Authoritative: whether mullet_core will accept that command right now. These come from
# the same predicates the goal and service handlers use, so a flag and an acceptance
# decision cannot disagree. Prefer them over any local guess about what a drone will take.
bool can_takeoff
bool can_land
bool can_return_home
bool can_start_mission
bool can_hold
