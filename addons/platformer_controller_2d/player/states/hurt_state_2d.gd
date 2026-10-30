extends State

## Hurt - brief stun + knockback when the Health component reports damage. Entered
## by the player via state_machine.transition_to("HurtState").

var _timer: float = 0.0

func enter() -> void:
	player.play_anim("hurt")
	_timer = maxf(player.config.hurt_stun_time, player.anim_duration("hurt"))

func update(delta: float) -> String:
	_timer -= delta
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.config.friction * 0.5 * delta)
	if not player.is_on_floor():
		player.apply_gravity(delta)
	player.move_and_slide()
	if _timer <= 0.0:
		return "IdleState"
	return ""
