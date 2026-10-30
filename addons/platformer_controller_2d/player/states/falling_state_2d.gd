extends State

## Falling - airborne and descending, with coyote time and a buffered-jump catch.

var coyote_timer: float = 0.0

func enter() -> void:
	# Grant coyote time only when we walked off a ledge (not after a jump).
	coyote_timer = 0.0 if player.is_falling_from_jump else player.config.coyote_time
	player.is_falling_from_jump = false

func update(delta: float) -> String:
	coyote_timer -= delta

	# Coyote / buffered jump.
	if player.jump_buffered() and coyote_timer > 0.0:
		return "JumpingState"
	if player.dash_pressed and player.can_dash():
		return "DashingState"

	if player.is_on_floor():
		if absf(player.get_move_input()) > 0.01:
			return "MovingState"
		return "IdleState"

	var h: float = player.get_move_input()
	if absf(h) > 0.01:
		player.velocity.x = move_toward(player.velocity.x, h * player.base_move_speed(), player.config.air_acceleration * delta)
	player.apply_gravity(delta)
	player.move_and_slide()
	return ""
