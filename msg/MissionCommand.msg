# Setpoint a mission framework streams to mullet_core on <ns>/command.
#
# mullet_core forwards it to PX4 only while the FSM is in MISSION; in every other state it is
# latched but never streamed. A stream older than command_timeout_s makes the drone hold its
# current position without leaving MISSION.
#
# PX4 local NED frame, SI units. The z components must be NaN: mullet_core holds the altitude
# the drone had on entering MISSION. Fields the selected mode does not use are ignored.
uint8 VELOCITY=1       # Track velocity_ned_mps; a finite acceleration_ned_mps2 is feedforward.
uint8 ACCELERATION=2   # Track acceleration_ned_mps2 directly; velocity_ned_mps is ignored.

builtin_interfaces/Time stamp
uint8 mode                       # VELOCITY or ACCELERATION. 0 (unset) is rejected.
float32[3] velocity_ned_mps      # [vx, vy, NaN]. Clamped by max_vx/vy_ned_mps.
float32[3] acceleration_ned_mps2 # [ax, ay, NaN], or all NaN for no feedforward in VELOCITY.
                                 # Clamped per axis by max_accel_ned_mps2.
float32 yaw_ned_rad              # Heading, clockwise from north. NaN faces the commanded
                                 # velocity in VELOCITY and keeps the hold heading otherwise.
