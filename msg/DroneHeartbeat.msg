uint32 schema_version
builtin_interfaces/Time stamp
uint64 sequence

string drone_id
uint8 vehicle_instance
uint8 target_system
string ros_namespace
string px4_fmu_prefix
string runtime_mode

string takeoff_action_path
string land_action_path
string enable_offboard_action_path
string disable_offboard_action_path
string arm_action_path
string disarm_action_path

uint16 state
string state_label
uint16 previous_state
string previous_state_label

bool core_alive
bool has_vehicle_status
bool has_local_position
bool has_land_detected
bool has_command_stream
bool has_action_state

bool armed
bool offboard
bool landed
bool local_position_valid
bool command_stream_valid

uint8 px4_nav_state
string px4_nav_state_label
uint8 px4_arming_state
string px4_arming_state_label

float64 x
float64 y
float64 z
float64 yaw

string active_action
bool active_action_cancelable
bool takeoff_active
bool land_active
bool enable_offboard_active
bool disable_offboard_active
bool arm_active
bool disarm_active

bool can_takeoff
bool can_land
bool can_enable_offboard
bool can_disable_offboard
bool can_arm
bool can_disarm
bool can_emergency_land
