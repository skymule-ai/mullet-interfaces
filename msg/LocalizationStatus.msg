# Which sources PX4's EKF2 is fusing on one Mullet drone: the operator's view of the active
# localization profile (mullet-px4: outdoor, outdoor-vio, indoor).
#
# Published by mullet_core on /mullet/localization_status at 1 Hz, keyed by drone_id like
# /mullet/heartbeat, once PX4's estimator_status_flags has arrived. Each field mirrors the
# EstimatorStatusFlags control-status bit named after it (cs_<field>).

builtin_interfaces/Time stamp
string drone_id

bool gnss_pos         # cs_gnss_pos: GNSS position fusion intended
bool gnss_vel         # cs_gnss_vel: GNSS velocity fusion intended
bool ev_pos           # cs_ev_pos: external vision position fusion intended
bool ev_vel           # cs_ev_vel: external vision velocity fusion intended
bool ev_yaw           # cs_ev_yaw: external vision yaw fusion intended
bool mag_hdg          # cs_mag_hdg or cs_mag_3d: magnetometer heading in use
bool baro_hgt         # cs_baro_hgt: baro height fused
bool rng_hgt          # cs_rng_hgt: range finder height fused
bool yaw_aligned      # cs_yaw_align: heading alignment complete (needed to arm in position modes)
bool dead_reckoning   # cs_inertial_dead_reckoning: nothing constrains horizontal velocity drift
