# mullet_interfaces

Shared ROS 2 interface definitions for the Mullet drone stack. This package is the wire
contract every other Mullet repository builds against: the semantic drone actions and the
operator-facing heartbeat message.

It holds IDL and compatibility notes only. No runtime logic, no policy, no code — behavior
lives in the repositories on either side of this contract.

## Contents

```text
action/Takeoff.action           Take off to a target altitude and hold
action/Land.action              Land and disarm (the only land command)
action/ReturnHome.action        Fly back above the takeoff point and hold
msg/DroneHeartbeat.msg          Full per-drone status snapshot
```

`Takeoff` is the only action with a goal payload (`altitude_m`, `yaw_rad`,
`use_current_yaw`); the other two take an empty goal. Every result is `bool success` plus a
human-readable `string message`. The files themselves carry field-level comments — read them,
or run `ros2 interface show mullet_interfaces/msg/DroneHeartbeat`.

Two instant commands need no IDL of their own: `start_mission` (HOLD → MISSION) and `hold`
(MISSION or return home → HOLD) are `std_srvs/srv/Trigger` services. Their paths are in the
heartbeat.

The drone's supervisor state is one of four labels: `IDLE` (on the ground), `TRANSITION`
(takeoff, land or return home in progress — `active_action` says which), `HOLD` (airborne,
holding position) and `MISSION` (following the external command stream).

## Who is on each side

`mullet-core` is the sole producer. It serves the actions and services and is the only
publisher of `DroneHeartbeat`, on `/mullet/heartbeat` at `schema_version` 3. What a command
is accepted from, what a field means, and when it changes are all decided there.

`mullet-paddock` is the operator-facing consumer: its gateway subscribes to the heartbeat
for drone discovery and status, and calls the actions and services on behalf of the UI.

Anything else that needs drone state or wants to command a drone depends on this package,
never on `mullet_core` directly. That is the point of the split — a consumer needs the
contract, not the supervisor.

## Requesting a change

A consumer that needs data it cannot see, or a command that does not exist, starts here —
against the IDL, not against `mullet-core`. Three steps, in this order, because a field is
not real until the producer fills it:

1. **Add it to this package.** Append the field at the end of its group in the `.msg`, or
   add a new `.action`, and register the new file in `CMakeLists.txt`. Comment what it means
   and what units it is in.
2. **`mullet-core` populates it.** A heartbeat field is assigned in `buildHeartbeatMessage()`
   (`src/flight/state_machine.cpp`); a new action needs a server and its acceptance rules.
   Core bumps `schema_version` for any change to `DroneHeartbeat.msg`.
3. **The consumer reads it.** For `mullet-paddock` that means `models.py` and
   `droneTypes.ts`, plus whichever component displays it.

All three land together. A field that exists here but is never assigned by core is
indistinguishable from a field that is always zero: `_heartbeat_to_status()` in paddock's
`ros2_adapter.py` reads every field through `getattr(msg, name, default)`, so the consumer
gets the default with no error and no log. Declaring a field is not the same as shipping one.

## Compatibility

- Additive changes are safe. Renames and removals are breaking, and they break silently on
  the consumer side rather than raising. Paddock's gateway warns when a heartbeat's
  `schema_version` is not the one it was built for.
- `state` and `previous_state` are `DroneState` enum ordinals and are not a stable contract.
  `state_label` and `previous_state_label` are — match on those.
- The `can_*` flags are authoritative for whether `mullet_core` will accept a command right
  now. They are computed from the same predicates the handlers use, so a client that trusts
  them can never be surprised by a rejection.
- The local position fields are zero unless `local_position_valid`, and lat/lon/alt are zero
  unless `global_position_valid`.

## Build and consume

Check the repository out into a colcon workspace's `src/`:

```bash
colcon build --packages-select mullet_interfaces
source install/setup.bash
ros2 interface show mullet_interfaces/msg/DroneHeartbeat
```

Consumers declare the dependency in their `package.xml`:

```xml
<depend>mullet_interfaces</depend>
```

`mullet-paddock`'s ROS 2 Docker image builds a vendored checkout at
`gateway/vendor/mullet_interfaces`; keep it up to date before rebuilding that image, or the
gateway compiles against an older contract than the drone publishes.
