extends CharacterBody2D

# Configuration
@export var config: PlayerConfig

# References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var state_machine: StateMachine = $StateMachine
@onready var coyote_timer: Timer = $CoyoteTimer

# State tracking
var was_on_floor: bool = false
var can_coyote_jump: bool = false
var last_horizontal_direction: float = 1.0

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# Create default config if none is assigned
	if not config:
		config = PlayerConfig.new()

	# Connect timer
	if coyote_timer:
		coyote_timer.timeout.connect(_on_coyote_timer_timeout)

func _physics_process(delta):
	# Track floor state before movement
	was_on_floor = is_on_floor()

	# Move and slide after state machine updates velocity
	move_and_slide()

	# Update camera
	update_camera_smoothly(delta)

func _on_coyote_timer_timeout():
	can_coyote_jump = false

# Input helper functions
func get_movement_input() -> float:
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		last_horizontal_direction = direction
	return direction

# Sprite helper functions
func update_sprite_direction(direction: float):
	if direction != 0 and animated_sprite:
		animated_sprite.flip_h = direction < 0

# Gravity helper
func get_gravity_force() -> float:
	return gravity * config.gravity_multiplier

# Coyote time functions
func start_coyote_timer():
	can_coyote_jump = true
	if coyote_timer:
		coyote_timer.start(config.coyote_time)

func reset_coyote_time():
	can_coyote_jump = false
	if coyote_timer:
		coyote_timer.stop()

# Dash helper
func can_dash() -> bool:
	# For now, always allow dashing
	# Can be extended with cooldown or stamina system
	return true

# Camera update
func update_camera_smoothly(delta):
	if not camera:
		return

	# Calculate target position with look-ahead
	var target_offset = Vector2.ZERO
	var horizontal_input = get_movement_input()

	if abs(horizontal_input) > 0.1:
		target_offset.x = horizontal_input * config.camera_look_ahead

	# Smoothly move camera to target position
	camera.offset = camera.offset.lerp(target_offset, config.camera_smoothing * delta)
