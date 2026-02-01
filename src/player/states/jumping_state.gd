extends State

var jump_held: bool = false

func enter():
	player.velocity.y = player.config.jump_velocity
	jump_held = true
	player.reset_coyote_time()
	if player.animated_sprite:
		player.animated_sprite.play("idle")

func physics_update(delta: float):
	# Handle horizontal movement
	var direction = player.get_movement_input()
	if direction != 0:
		player.velocity.x = move_toward(
			player.velocity.x,
			direction * player.config.movement_speed,
			player.config.acceleration * delta
		)
		player.update_sprite_direction(direction)

	# Handle variable jump height
	if Input.is_action_pressed("jump") and jump_held and player.velocity.y < 0:
		player.velocity.y += player.get_gravity_force() * player.config.jump_hold_multiplier * delta
	else:
		player.velocity.y += player.get_gravity_force() * delta

	# Stop jump hold when button is released or moving downward
	if Input.is_action_just_released("jump") or player.velocity.y >= 0:
		jump_held = false

	# Check for state transitions
	if player.velocity.y >= 0:
		state_machine.transition_to("Falling")
	elif Input.is_action_just_pressed("dash") and player.can_dash():
		state_machine.transition_to("Dashing")

func exit():
	jump_held = false
