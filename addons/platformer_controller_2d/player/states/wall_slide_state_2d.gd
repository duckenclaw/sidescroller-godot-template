extends State

## Wall slide - cling to and slide down a wall, with a wall-jump. Optional mechanic.

func enter() -> void:
	player.play_anim("wall_slide")

func update(delta: float) -> String:
	if player.is_on_floor():
		return "IdleState"
	if not player.is_on_wall():
		return "FallingState"

	# Wall jump: push off the wall and up.
	if player.jump_buffered():
		var n: Vector2 = player.get_wall_normal()
		player.velocity.x = n.x * player.config.wall_jump_push
		player.velocity.y = player.config.jump_velocity
		player.consume_jump_buffer()
		player.is_falling_from_jump = false
		return "JumpingState"

	# Slow, capped descent; keep a little push into the wall so contact holds.
	player.velocity.y = minf(player.velocity.y + player.config.gravity * delta, player.config.wall_slide_speed)
	player.velocity.x = -player.get_wall_normal().x * 30.0
	player.move_and_slide()

	# Let go if the player stops pressing toward the wall.
	if absf(player.get_move_input()) < 0.01:
		return "FallingState"
	return ""
