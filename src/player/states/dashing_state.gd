extends State

var dash_timer: float = 0.0
var dash_direction: float = 1.0

func enter():
	# Use last movement direction, default to facing direction
	dash_direction = player.last_horizontal_direction
	if dash_direction == 0:
		dash_direction = 1.0 if not player.animated_sprite.flip_h else -1.0

	player.velocity.x = dash_direction * player.config.dash_speed
	player.velocity.y = 0
	dash_timer = player.config.dash_duration

	if player.animated_sprite:
		player.animated_sprite.play("idle")

func physics_update(delta: float):
	dash_timer -= delta

	# Maintain dash velocity
	player.velocity.x = dash_direction * player.config.dash_speed

	# Check if dash is over
	if dash_timer <= 0:
		if player.is_on_floor():
			if player.get_movement_input() != 0:
				state_machine.transition_to("Moving")
			else:
				state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Falling")

func exit():
	dash_timer = 0.0
