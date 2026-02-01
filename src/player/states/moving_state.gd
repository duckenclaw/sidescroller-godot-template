extends State

func enter():
	if player.animated_sprite:
		player.animated_sprite.play("run")

func physics_update(delta: float):
	var direction = player.get_movement_input()

	# Apply horizontal movement
	if direction != 0:
		player.velocity.x = move_toward(
			player.velocity.x,
			direction * player.config.movement_speed,
			player.config.acceleration * delta
		)
		# Update sprite direction
		player.update_sprite_direction(direction)
	else:
		# No input, transition to idle
		state_machine.transition_to("Idle")
		return

	# Apply gravity
	if not player.is_on_floor():
		player.velocity.y += player.get_gravity_force() * delta

	# Check for state transitions
	if not player.is_on_floor():
		state_machine.transition_to("Falling")
	elif Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jumping")
	elif Input.is_action_just_pressed("dash") and player.can_dash():
		state_machine.transition_to("Dashing")

func exit():
	pass
