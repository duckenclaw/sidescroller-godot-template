extends State

## Block - hold the "block" action to guard (plays block, then a block-idle loop).
## While blocking, incoming damage is reduced per config.block_damage_reduction.
## Optional mechanic.

func enter() -> void:
	player.play_anim("block")
	player.velocity.x = 0.0
	if player.health and player.config.block_damage_reduction >= 1.0:
		player.health.invulnerable = true

func update(delta: float) -> String:
	if not player.is_on_floor():
		return "FallingState"
	if not Input.is_action_pressed("block"):
		return "IdleState"
	# Once the raise-guard anim finishes, hold the block-idle loop.
	if player.sprite and (player.sprite.animation == "block") and not player.sprite.is_playing():
		player.play_anim("block_idle")
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.config.friction * delta)
	player.move_and_slide()
	return ""

func exit() -> void:
	if player.health:
		player.health.invulnerable = false
