extends State

## Crouching - grounded, slow movement (optional mechanic).

func update(delta: float) -> String:
	if not player.is_on_floor():
		player.is_falling_from_jump = false
		return "FallingState"
	if player.jump_buffered():
		return "JumpingState"
	if not player.is_crouch_toggled:
		return "IdleState"

	var h: float = player.get_move_input()
	if absf(h) > 0.01:
		player.velocity.x = move_toward(player.velocity.x, h * player.config.crouch_speed, player.config.acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.config.friction * delta)
	player.move_and_slide()
	return ""
