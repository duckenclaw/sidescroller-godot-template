extends State

## Death - plays the death animation and stays. Entered by the player via
## state_machine.transition_to("DeathState") when Health reports death.

func enter() -> void:
	player.play_anim("death")
	player.velocity.x = 0.0

func update(delta: float) -> String:
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.config.friction * delta)
	if not player.is_on_floor():
		player.apply_gravity(delta)
	player.move_and_slide()
	return ""
