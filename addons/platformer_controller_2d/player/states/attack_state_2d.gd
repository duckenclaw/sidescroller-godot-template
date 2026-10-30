extends State

## Attack - a grounded 3-hit combo (attack1 -> attack2 -> attack3). Tapping attack
## again in the latter part of a swing chains the next hit. Optional mechanic.

var _combo: int = 1
var _timer: float = 0.0

func enter() -> void:
	_combo = 1
	_start()

func _start() -> void:
	var anim := "attack%d" % _combo
	player.play_anim(anim)
	_timer = player.anim_duration(anim)
	player.velocity.x = 0.0

func update(delta: float) -> String:
	_timer -= delta

	# Chain the combo if attack is tapped near the end of the current swing.
	if _timer <= player.config.attack_combo_window and player.attack_pressed and _combo < 3:
		_combo += 1
		_start()
		return ""

	player.velocity.x = move_toward(player.velocity.x, 0.0, player.config.friction * delta)
	if not player.is_on_floor():
		player.apply_gravity(delta)
	player.move_and_slide()

	if _timer <= 0.0:
		if not player.is_on_floor():
			return "FallingState"
		return "MovingState" if absf(player.get_move_input()) > 0.01 else "IdleState"
	return ""
