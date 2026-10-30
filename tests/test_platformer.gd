extends SceneTree

## Headless tests for the 2D platformer controller: input provisioning, the
## walk/run toggle, and modular mechanics (flags + removable states). Run with:
##   godot --headless --path . --script tests/test_platformer.gd

const PLAYER := "res://addons/platformer_controller_2d/player/player.tscn"

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
	check(InputMap.has_action("jump"), "jump action provisioned")
	check(InputMap.has_action("walk_run_toggle"), "walk_run_toggle provisioned (Capslock)")

	p.is_running = true
	check(is_equal_approx(p.base_move_speed(), p.config.run_speed), "run mode uses run_speed")
	p.is_running = false
	check(is_equal_approx(p.base_move_speed(), p.config.walk_speed), "walk mode uses walk_speed")

	check(p.state_machine.has_state("JumpingState"), "has_state finds a core state")
	check(p.can_dash(), "dash enabled by default")
	p.config.enable_dash = false
	check(not p.can_dash(), "config.enable_dash=false disables dash")
	p.free()

func _test_removal() -> void:
	var p: Node = (load(PLAYER) as PackedScene).instantiate()
	var dash := p.get_node_or_null("StateMachine/DashingState")
	check(dash != null, "DashingState present in default player")
	if dash:
		dash.free()
	root.add_child(p)
	await process_frame
	await physics_frame
	check(not p.state_machine.has_state("DashingState"), "removed DashingState not registered")
	check(not p.can_dash(), "deleting DashingState disables dash")
	check(p.state_machine.has_state("IdleState"), "core states unaffected")
	p.free()
