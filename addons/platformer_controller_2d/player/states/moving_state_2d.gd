extends State

## Moving - grounded horizontal movement with walk/run toggle, sprint and crouch.

func enter() -> void:
	player.play_anim("run")

func update(delta: float) -> String:
	if not player.is_on_floor():
		player.is_falling_from_jump = false
		return "FallingState"
	if player.attack_pressed and player.can_attack():
		return "AttackState"
	if Input.is_action_pressed("block") and player.can_block():
		return "BlockState"
	if player.jump_buffered():
		return "JumpingState"
	if player.dash_pressed and player.can_dash():
		return "DashingState"
	if player.is_crouch_toggled and player._has_state("CrouchingState"):
		return "CrouchingState"

	var h: float = player.get_move_input()
	if absf(h) <= 0.01:
		return "IdleState"

	var target_speed: float = player.base_move_speed()
	if player.config.enable_sprint and Input.is_action_pressed("sprint"):
		target_speed = player.config.sprint_speed

	player.velocity.x = move_toward(player.velocity.x, h * target_speed, player.config.acceleration * delta)
	player.move_and_slide()
	return ""
