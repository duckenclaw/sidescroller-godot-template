extends State

## Idle - grounded, no horizontal input.

func update(delta: float) -> String:
	if not player.is_on_floor():
		player.is_falling_from_jump = false
		return "FallingState"
	if player.jump_buffered():
		return "JumpingState"
	if player.dash_pressed and player.can_dash():
		return "DashingState"
	if player.is_crouch_toggled and player._has_state("CrouchingState"):
		return "CrouchingState"
	if absf(player.get_move_input()) > 0.01:
		return "MovingState"

	player.velocity.x = move_toward(player.velocity.x, 0.0, player.config.friction * delta)
	player.move_and_slide()
	return ""
