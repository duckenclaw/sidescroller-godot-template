# Sidescroller Godot Template

A 2D sidescroller starter for **Godot 4**, built on the shared
**[godot-game-kit](https://github.com/duckenclaw/godot-game-kit)** addons plus a
state-machine 2D platformer controller. Sister template to the
[FPS template](https://github.com/duckenclaw/fps-godot-template) — same shared
services, same modular-mechanics design, different genre.

## Install

The reusable kits under `addons/` are **git submodules**, so clone recursively:

```bash
git clone --recurse-submodules https://github.com/duckenclaw/sidescroller-godot-template
# already cloned without it?
git submodule update --init --recursive
```

Open in Godot 4.3+ and press F5. The demo level drops a character onto a floor
with two platforms.

## Controls (defaults)

| Action | Keys |
|--------|------|
| Move | A / D or ← / → |
| Jump | Space / W / ↑ (hold for higher) |
| Sprint | Shift (hold) |
| Walk/Run toggle | Caps Lock |
| Dash | L |
| Crouch | S / ↓ |
| Interact | E |

All bindings are registered at startup and can be rebound/persisted via the
Settings Kit.

## What's inside

- **Shared kits (submodules):** `core` (services), `settings_kit` (settings +
  rebinding), `inventory_kit` (items), `components_kit` (Health, StateMachine).
- **`platformer_controller_2d`:** a `CharacterBody2D` controller with a state
  machine (idle / moving / jumping / falling / dashing / crouching), variable-height
  jump with coyote time + jump buffer, a `Camera2D` follower and an `AnimatedSprite2D`.

## Modular mechanics

Exactly like the FPS controller — two ways to turn abilities off:

1. **Config flags** on `PlatformerConfig2D` → Inspector *Mechanics* group:
   `enable_sprint`, `enable_crouch`, `enable_walk_run_toggle`, `enable_dash`.
2. **Delete the state node** (`DashingState`, `CrouchingState`) from the player's
   `StateMachine`. Every transition into an optional state is gated by *flag AND
   state-present*, so either method disables it cleanly.

Core walking/running, jumping and falling are always on.

## Start your own game

This repo is a GitHub **template** — *Use this template*, clone with
`--recurse-submodules`, then:

1. Rename the project in `project.godot` and set your own icon.
2. Swap the character art: replace `addons/platformer_controller_2d/player/player_frames.tres`
   with your own `SpriteFrames` (idle / run / jump / fall).
3. Build levels under `src/levels/` using `addons/platformer_controller_2d/player/player.tscn`.
4. Tune feel on the `PlatformerConfig2D` resource.
5. Edit the rebindable action list in `src/globals/game_settings.gd`.

## Validate

```bash
godot --headless --path . --import
godot --headless --path . --script tests/test_platformer.gd   # expects RESULT: 0 failures
```

## License

MIT — see [LICENSE](LICENSE).
