extends SceneTree

## Headless tests for the 2D platformer controller: input provisioning, walk/run
## toggle, the full animation set, and modular mechanics (flags + removable states).
## Run: godot --headless --path . --script tests/test_platformer.gd

const PLAYER := "res://addons/platformer_controller_2d/player/player.tscn"
const EXPECTED_ANIMS := ["idle", "run", "jump", "fall", "attack1", "attack2", "attack3",
	"roll", "hurt", "death", "block", "block_idle", "wall_slide", "ledge_grab"]

var _failures := 0

func check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS: " + msg)
	else:
		_failures += 1
		print("FAIL: " + msg)

func _initialize() -> void:
	_run()

func _run() -> void:
	await _test_core()
	await _test_removal()
	await _test_health_reactions()
	print("RESULT: %d failures" % _failures)
	quit(1 if _failures > 0 else 0)

func _spawn() -> Node:
	var p: Node = (load(PLAYER) as PackedScene).instantiate()
	root.add_child(p)
	await process_frame
	await physics_frame
	return p

func _test_core() -> void:
	var p := await _spawn()
	for a in ["jump", "attack", "block", "dash", "walk_run_toggle"]:
		check(InputMap.has_action(a), "action provisioned: " + a)

	p.is_running = true
	check(is_equal_approx(p.base_move_speed(), p.config.run_speed), "run mode uses run_speed")
	p.is_running = false
	check(is_equal_approx(p.base_move_speed(), p.config.walk_speed), "walk mode uses walk_speed")

	for s in ["IdleState", "MovingState", "JumpingState", "FallingState", "DashingState", "AttackState", "HurtState", "DeathState", "BlockState", "WallSlideState"]:
		check(p.state_machine.has_state(s), "state present: " + s)
	check(not p.state_machine.has_state("CrouchingState"), "CrouchingState removed (no crouch anim)")

	check(p.can_dash() and p.can_attack() and p.can_block() and p.can_wall_slide(), "all optional mechanics enabled by default")
	p.config.enable_attack = false
	check(not p.can_attack(), "config.enable_attack=false disables attack")

	# SpriteFrames completeness
	var sf: SpriteFrames = p.sprite.sprite_frames
	var missing := []
	for a in EXPECTED_ANIMS:
		if not sf.has_animation(a):
			missing.append(a)
	check(missing.is_empty(), "SpriteFrames has all %d HeroKnight animations" % EXPECTED_ANIMS.size())
	p.free()

func _test_removal() -> void:
	var p: Node = (load(PLAYER) as PackedScene).instantiate()
	var dash := p.get_node_or_null("StateMachine/DashingState")
	if dash:
		dash.free()
	root.add_child(p)
	await process_frame
	await physics_frame
	check(not p.can_dash(), "deleting DashingState disables dash")
	check(p.can_attack(), "other mechanics unaffected")
	p.free()

func _test_health_reactions() -> void:
	var p := await _spawn()
	# Damage -> Hurt state
	p.health.take_damage(10.0)
	await physics_frame
	check(p.state_machine.get_current_state_name() == "HurtState", "damage enters HurtState")
	# Kill -> Death state + is_dead
	p.health.take_damage(1000.0)
	await physics_frame
	check(p.is_dead and p.state_machine.get_current_state_name() == "DeathState", "lethal damage enters DeathState")
	p.free()
