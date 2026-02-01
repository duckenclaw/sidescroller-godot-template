extends State

var can_coyote_jump: bool = false

func enter():
	# Start coyote time if we just walked off a ledge
	if player.was_on_floor and player.velocity.y >= 0:
		can_coyote_jump = true
		player.start_coyote_timer()
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

	# Apply gravity
	player.velocity.y += player.get_gravity_force() * delta

	# Check for coyote jump
	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor() or (can_coyote_jump and player.can_coyote_jump):
			state_machine.transition_to("Jumping")
			return

	# Check for state transitions
	if player.is_on_floor():
		if player.get_movement_input() != 0:
			state_machine.transition_to("Moving")
		else:
			state_machine.transition_to("Idle")
	elif Input.is_action_just_pressed("dash") and player.can_dash():
		state_machine.transition_to("Dashing")

func exit():
	can_coyote_jump = false
	player.reset_coyote_time()
