class_name PlatformerPlayer2D
extends CharacterBody2D

## 2D sidescroller character controller. State-machine driven (reuses the shared
## StateMachine/State from the Components Kit), with the same modular-mechanics
## pattern as the FPS controller: abilities toggle via PlatformerConfig2D flags and
## optional state nodes can be deleted to remove a mechanic.

@export var config: PlatformerConfig2D

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var camera: Camera2D = get_node_or_null("Camera2D")
@onready var state_machine: StateMachine = $StateMachine
@onready var health: Health = get_node_or_null("Health")

# Input flags (set each physics frame, read by states)
var jump_pressed: bool = false
var dash_pressed: bool = false
var crouch_pressed: bool = false

# Movement state
var is_running: bool = true            # walk/run toggle (Capslock); true = run
var is_crouch_toggled: bool = false
var facing: int = 1                    # 1 = right, -1 = left (last horizontal dir)
var is_falling_from_jump: bool = false

# Jump buffer: lets a jump pressed slightly before landing still fire.
var _jump_buffer: float = 0.0

# Game state
var is_paused: bool = false

func _ready() -> void:
	if not config:
		config = PlatformerConfig2D.new()
	_ensure_default_actions()
	if camera:
		camera.zoom = Vector2(config.camera_zoom, config.camera_zoom)
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = config.camera_smoothing

func _physics_process(delta: float) -> void:
	if is_paused:
		return

	# Latch discrete inputs for the states.
	jump_pressed = Input.is_action_just_pressed("jump")
	dash_pressed = Input.is_action_just_pressed("dash")
	crouch_pressed = Input.is_action_just_pressed("crouch")

	# Jump buffer countdown.
	if jump_pressed:
		_jump_buffer = config.jump_buffer_time
	elif _jump_buffer > 0.0:
		_jump_buffer -= delta

	# Crouch toggle (if enabled).
	if crouch_pressed and config.enable_crouch:
		is_crouch_toggled = not is_crouch_toggled

	# Track facing from horizontal input.
	var h := get_move_input()
	if h > 0.01:
		facing = 1
	elif h < -0.01:
		facing = -1

	_update_animation()

func _input(event: InputEvent) -> void:
	if is_paused:
		return
	# Walk/run toggle (Capslock by default).
	if config.enable_walk_run_toggle and event.is_action_pressed("walk_run_toggle"):
		is_running = not is_running
	# Interact (tap): trigger interact() on an overlapping "interactable".
	if event.is_action_pressed("interact"):
		_try_interact()

# ---- Movement helpers -------------------------------------------------------

## Horizontal input axis (-1..1). Zero while paused.
func get_move_input() -> float:
	if is_paused:
		return 0.0
	return Input.get_axis("left", "right")

## Base horizontal speed honoring the walk/run toggle. Sprint/crouch override it
## in the moving state.
func base_move_speed() -> float:
	if config.enable_walk_run_toggle and not is_running:
		return config.walk_speed
	return config.run_speed

## True while a jump is buffered (pressed within jump_buffer_time).
func jump_buffered() -> bool:
	return _jump_buffer > 0.0

func consume_jump_buffer() -> void:
	_jump_buffer = 0.0

func apply_gravity(delta: float) -> void:
	velocity.y = minf(velocity.y + config.gravity * delta, config.max_fall_speed)

# ---- Optional-mechanic gates (flag AND state node present) -------------------

func _has_state(state_name: String) -> bool:
	return state_machine != null and state_machine.has_state(state_name)

func can_dash() -> bool:
	return config.enable_dash and _has_state("DashingState")

# ---- Interaction ------------------------------------------------------------

func _try_interact() -> void:
	var area: Area2D = get_node_or_null("InteractArea")
	if area == null:
		return
	for body in area.get_overlapping_bodies():
		if body.has_method("interact"):
			body.interact()
			return
	for a in area.get_overlapping_areas():
		if a.has_method("interact"):
			a.interact()
			return

# ---- Animation --------------------------------------------------------------

func _update_animation() -> void:
	if sprite == null:
		return
	if facing != 0:
		sprite.flip_h = facing < 0
	var anim := "idle"
	if is_on_floor() and absf(velocity.x) > 10.0:
		anim = "run"
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		if sprite.animation != anim or not sprite.is_playing():
			sprite.play(anim)

# ---- Input provisioning -----------------------------------------------------

## Register this controller's input actions with sane defaults if the host project
## hasn't defined them, so the addon works dropped into a bare project. The project
## or the rebind UI can override the bindings afterwards.
func _ensure_default_actions() -> void:
	_ensure_key("left", [KEY_A, KEY_LEFT])
	_ensure_key("right", [KEY_D, KEY_RIGHT])
	_ensure_key("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_ensure_key("dash", [KEY_L, KEY_SHIFT])
	_ensure_key("sprint", [KEY_SHIFT])
	_ensure_key("crouch", [KEY_S, KEY_DOWN])
	_ensure_key("interact", [KEY_E])
	_ensure_key("walk_run_toggle", [KEY_CAPSLOCK])
	_ensure_key("pause", [KEY_ESCAPE])

func _ensure_key(action: String, keycodes: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for kc in keycodes:
		var ev := InputEventKey.new()
		ev.physical_keycode = kc
		InputMap.action_add_event(action, ev)
