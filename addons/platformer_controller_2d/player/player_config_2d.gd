class_name PlatformerConfig2D
extends Resource

## Configuration for the 2D sidescroller character controller. Mirrors the FPS
## controller's PlayerConfig so tuning and the modular-mechanics pattern feel the
## same across genres.

# Mechanics toggles — turn abilities on/off per game. Disabling one also makes it
# safe to delete that ability's state node from the player's StateMachine (see the
# can_* helpers in player_2d.gd). Core walking/running, jumping and falling have no
# flags; they always run.
@export_group("Mechanics")
@export var enable_sprint: bool = true          ## Hold-to-sprint (faster while holding "sprint").
@export var enable_crouch: bool = true          ## Crouch (needs a CrouchingState node).
@export var enable_walk_run_toggle: bool = true ## Capslock toggles base speed walk<->run.
@export var enable_dash: bool = true            ## Horizontal dash (needs a DashingState node).
@export_group("")

# Horizontal movement
@export_group("Movement")
@export var walk_speed: float = 140.0   ## Base speed in "walk" mode.
@export var run_speed: float = 240.0    ## Base speed in "run" mode (default).
@export var sprint_speed: float = 340.0 ## Speed while holding "sprint".
@export var crouch_speed: float = 90.0
@export var acceleration: float = 2000.0
@export var friction: float = 1800.0
@export var air_acceleration: float = 1400.0
@export_group("")

# Jump
@export_group("Jump")
@export var jump_velocity: float = -420.0        ## Upward (negative y) impulse.
@export var jump_cut_multiplier: float = 0.45    ## Velocity kept when jump released early.
@export var coyote_time: float = 0.12            ## Grace after leaving a ledge.
@export var jump_buffer_time: float = 0.1        ## Pressed-just-before-landing grace.
@export_group("")

# Dash
@export_group("Dash")
@export var dash_speed: float = 520.0
@export var dash_duration: float = 0.18
@export_group("")

# Physics
@export var gravity: float = 1200.0        ## Falling acceleration (y-down).
@export var max_fall_speed: float = 900.0

# Camera (Camera2D follower)
@export_group("Camera")
@export var camera_smoothing: float = 6.0
@export var camera_look_ahead: float = 48.0
@export var camera_zoom: float = 1.5
@export_group("")
