# CLAUDE.md

Guidance for AI coding sessions working in this repository.

## What this is

`mullet_interfaces` is the ROS 2 wire contract for the Mullet stack: three action definitions
(`Takeoff`, `Land`, `ReturnHome`), `msg/DroneHeartbeat.msg`, and the mission API
(`msg/MissionCommand.msg`, `msg/MissionStatus.msg`, `srv/LoadMission.srv`). The instant
commands `start_mission` and `hold` are `std_srvs/srv/Trigger` services and have no IDL here.
`mullet-core` produces the actions, services and heartbeat and consumes `MissionCommand`;
mission framework nodes produce `MissionCommand`, `MissionStatus` and `LoadMission`.
`mullet-paddock` and any future consumer depend on this package rather than on
`mullet_core` itself.

**IDL only.** No runtime logic, no policy, no defaults that encode behavior. Any rule about
*when* an action is accepted or *what* a field means belongs in the producer, and is recorded
here as a comment.

## Changing the contract

A change lands in three repositories in this order, and all three together:
this package declares the field or action, `mullet-core` populates it in
`buildHeartbeatMessage()` (`src/flight/state_machine.cpp`) or serves it and bumps
`schema_version`, then the consumer reads it.

Declared is not the same as populated. Paddock reads heartbeat fields through
`getattr(msg, name, default)`, so a field this package declares but core never assigns
arrives as the default with no error and no log. Never assume a field is live because it is
in the `.msg` — check `buildHeartbeatMessage()`.

Additive changes are safe; renames and removals break consumers silently. `state_label` is
the stable state contract, not the numeric `state` ordinal.

## Build

```bash
colcon build --packages-select mullet_interfaces
ros2 interface show mullet_interfaces/msg/DroneHeartbeat
```

New `.msg`, `.srv` or `.action` files must be registered in `rosidl_generate_interfaces()` in
`CMakeLists.txt` or they are silently not generated.

`README.md` carries the full contract description, the request protocol, and the consumer
list. The field-level detail lives in the `.msg` and `.action` files themselves — that is
the documentation that travels to every consumer via `ros2 interface show`.
