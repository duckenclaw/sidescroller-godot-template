# Platformer Controller 2D (`platformer_controller_2d`)

A state-machine 2D sidescroller character controller for Godot 4: walk/run/sprint/
crouch, variable-height jump with coyote time + jump buffer, an optional dash, a
`Camera2D` follower and an `AnimatedSprite2D` hook. Mechanics are modular (config
flags + removable state nodes), mirroring the FPS Controller.

Part of the **[godot-game-kit](https://github.com/duckenclaw/godot-game-kit)**
ecosystem.

## Install

**Git submodule (recommended)** — root-layout, drops into `addons/`:

```bash
git submodule add https://github.com/duckenclaw/godot-platformer-controller-2d addons/platformer_controller_2d
git submodule add https://github.com/duckenclaw/godot-components-kit addons/components_kit
git submodule update --init
```

Enable **Platformer Controller 2D** and **Components Kit** in *Project Settings → Plugins*,
then instance `player/player.tscn`.

## Dependencies

- **godot-components-kit** (`StateMachine`, `State`, `Health`).

## Modular mechanics

Turn abilities off via `PlatformerConfig2D` flags (`enable_sprint`, `enable_crouch`,
`enable_walk_run_toggle`, `enable_dash`) or by deleting the matching state node
(`DashingState`, `CrouchingState`) from the player's `StateMachine`. Core
walk/run movement, jumping and falling are always on.

## License

MIT — see [LICENSE](LICENSE).
