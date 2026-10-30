extends State

## Jumping - variable height; hands off to Falling once rising stops.

func enter() -> void:
	player.velocity.y = player.config.jump_velocity
	player.is_crouch_toggled = false
	player.consume_jump_buffer()

func update(delta: float) -> String:
	# Variable jump height: releasing jump early cuts the upward velocity.
	if not Input.is_action_pressed("jump") and player.velocity.y < 0.0:
		player.velocity.y *= player.config.jump_cut_multiplier

	if player.dash_pressed and player.can_dash():
		return "DashingState"

	if player.velocity.y >= 0.0:
		player.is_falling_from_jump = true
		return "FallingState"

	_air_move(delta)
	player.apply_gravity(delta)
	player.move_and_slide()
	return ""

func _air_move(delta: float) -> void:
	var h: float = player.get_move_input()
	if absf(h) > 0.01:
		player.velocity.x = move_toward(player.velocity.x, h * player.base_move_speed(), player.config.air_acceleration * delta)
