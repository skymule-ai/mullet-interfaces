# Setpoint a mission framework streams to mullet_core on <ns>/command.
#
# mullet_core forwards it to PX4 only while the FSM is in MISSION; in every other state it is
# latched but never streamed. A stream older than command_timeout_s makes the drone hold its
# current position without leaving MISSION.
#
# PX4 local NED frame, SI units. Fields the selected mode does not use are ignored.
# Planar modes (VELOCITY, ACCELERATION): the z components must be NaN, and mullet_core holds
# the altitude the drone had on entering MISSION.
# 3D modes (VELOCITY_3D, ACCELERATION_3D): the z components of the tracked vector must be
# finite, and a stale stream holds the altitude the drone has at that moment.
uint8 VELOCITY=1         # Track velocity_ned_mps; a finite acceleration_ned_mps2 is feedforward.
uint8 ACCELERATION=2     # Track acceleration_ned_mps2 directly; velocity_ned_mps is ignored.
uint8 VELOCITY_3D=3      # VELOCITY on all three axes; feedforward sets all three or none.
uint8 ACCELERATION_3D=4  # ACCELERATION on all three axes.

builtin_interfaces/Time stamp
uint8 mode                       # One of the constants above. 0 (unset) is rejected.
float32[3] velocity_ned_mps      # [vx, vy, NaN], or [vx, vy, vz] in VELOCITY_3D. Clamped by
                                 # max_vx/vy/vz_ned_mps.
float32[3] acceleration_ned_mps2 # [ax, ay, NaN], [ax, ay, az] in the 3D modes, or all NaN for
                                 # no feedforward. Clamped per axis by max_accel_ned_mps2.
float32 yaw_ned_rad              # Heading, clockwise from north. NaN faces the commanded
                                 # horizontal velocity in the VELOCITY modes and keeps the
                                 # hold heading otherwise.
