extends State

func enter():
	player.velocity.x = 0
	if player.animated_sprite:
		player.animated_sprite.play("idle")

func physics_update(delta: float):
	# Apply friction
	player.velocity.x = move_toward(player.velocity.x, 0, player.config.friction * delta)

	# Apply gravity
	if not player.is_on_floor():
		player.velocity.y += player.get_gravity_force() * delta

	# Check for state transitions
	if not player.is_on_floor():
		state_machine.transition_to("Falling")
	elif player.get_movement_input() != 0:
		state_machine.transition_to("Moving")
	elif Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jumping")
	elif Input.is_action_just_pressed("dash") and player.can_dash():
		state_machine.transition_to("Dashing")

func exit():
	pass
