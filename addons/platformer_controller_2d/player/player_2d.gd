class_name PlatformerPlayer2D
extends CharacterBody2D

## 2D sidescroller character controller. State-machine driven (reuses the shared
## StateMachine/State from the Components Kit), with a comprehensive animation
## controller (idle/run/jump/fall/roll/attack-combo/block/wall-slide/hurt/death)
## and the same modular-mechanics pattern as the FPS controller: abilities toggle
## via PlatformerConfig2D flags, and optional state nodes can be deleted to remove
## a mechanic. Each state owns its animation; this script drives facing/flip and
## routes Health damage/death into the Hurt/Death states.

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
var attack_pressed: bool = false

# Movement state
var is_running: bool = true            # walk/run toggle (Capslock); true = run
var is_crouch_toggled: bool = false
var facing: int = 1                    # 1 = right, -1 = left (last horizontal dir)
var is_falling_from_jump: bool = false
var is_dead: bool = false

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
	# Route health events into the reaction states.
	if health:
		if not health.damaged.is_connected(_on_damaged):
			health.damaged.connect(_on_damaged)
		if not health.died.is_connected(_on_died):
			health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if is_paused or is_dead:
		return

	jump_pressed = Input.is_action_just_pressed("jump")
	dash_pressed = Input.is_action_just_pressed("dash")
	crouch_pressed = Input.is_action_just_pressed("crouch")
	attack_pressed = Input.is_action_just_pressed("attack")

	if jump_pressed:
		_jump_buffer = config.jump_buffer_time
	elif _jump_buffer > 0.0:
		_jump_buffer -= delta

	if crouch_pressed and config.enable_crouch:
		is_crouch_toggled = not is_crouch_toggled

	var h := get_move_input()
	if h > 0.01:
		facing = 1
	elif h < -0.01:
		facing = -1

	_update_facing_flip()

func _input(event: InputEvent) -> void:
	if is_paused or is_dead:
		return
	if config.enable_walk_run_toggle and event.is_action_pressed("walk_run_toggle"):
		is_running = not is_running
	if event.is_action_pressed("interact"):
		_try_interact()

# ---- Movement helpers -------------------------------------------------------

func get_move_input() -> float:
	if is_paused or is_dead:
		return 0.0
	return Input.get_axis("left", "right")

func base_move_speed() -> float:
	if config.enable_walk_run_toggle and not is_running:
		return config.walk_speed
	return config.run_speed

func jump_buffered() -> bool:
	return _jump_buffer > 0.0

func consume_jump_buffer() -> void:
	_jump_buffer = 0.0

func apply_gravity(delta: float) -> void:
	velocity.y = minf(velocity.y + config.gravity * delta, config.max_fall_speed)

# ---- Animation --------------------------------------------------------------

## Play an animation by name (if present). States call this on enter; movement
## states also re-assert it. Flip is handled separately so facing stays live.
func play_anim(anim: String) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(anim):
		return
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)

## Length in seconds of an animation (frames / fps) — used by one-shot states.
func anim_duration(anim: String) -> float:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		var c: int = sprite.sprite_frames.get_frame_count(anim)
		var s: float = sprite.sprite_frames.get_animation_speed(anim)
		if s > 0.0:
			return float(c) / s
	return 0.3

func _update_facing_flip() -> void:
	if sprite and facing != 0:
		sprite.flip_h = facing < 0

# ---- Optional-mechanic gates (flag AND state node present) -------------------

func _has_state(state_name: String) -> bool:
	return state_machine != null and state_machine.has_state(state_name)

func can_dash() -> bool:
	return config.enable_dash and _has_state("DashingState")

func can_attack() -> bool:
	return config.enable_attack and _has_state("AttackState")

func can_block() -> bool:
	return config.enable_block and _has_state("BlockState")

func can_wall_slide() -> bool:
	return config.enable_wall_slide and _has_state("WallSlideState")

# ---- Health reactions -------------------------------------------------------

func _on_damaged(_amount: float, source: Node) -> void:
	if is_dead:
		return
	if _has_state("HurtState"):
		# Knock back away from the damage source.
		var dir := -facing
		if source is Node2D:
			dir = signi(int(global_position.x - (source as Node2D).global_position.x))
			if dir == 0:
				dir = -facing
		velocity.x = dir * config.hurt_knockback
		state_machine.transition_to("HurtState")

func _on_died() -> void:
	if is_dead:
		return
	is_dead = true
	if _has_state("DeathState"):
		state_machine.transition_to("DeathState")

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

# ---- Input provisioning -----------------------------------------------------

func _ensure_default_actions() -> void:
	_ensure_key("left", [KEY_A, KEY_LEFT])
	_ensure_key("right", [KEY_D, KEY_RIGHT])
	_ensure_key("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_ensure_key("dash", [KEY_L])
	_ensure_key("sprint", [KEY_SHIFT])
	_ensure_key("crouch", [KEY_S, KEY_DOWN])
	_ensure_key("attack", [KEY_J])
	_ensure_key("block", [KEY_K])
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
