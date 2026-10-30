extends State

## Dashing - a short horizontal burst in the facing direction (optional mechanic).

var dash_timer: float = 0.0
var dash_dir: int = 1

func enter() -> void:
	dash_timer = player.config.dash_duration
	dash_dir = player.facing if player.facing != 0 else 1
	player.velocity = Vector2(dash_dir * player.config.dash_speed, 0.0)

func update(delta: float) -> String:
	dash_timer -= delta
	if dash_timer <= 0.0:
		if player.is_on_floor():
			return "MovingState" if absf(player.get_move_input()) > 0.01 else "IdleState"
		return "FallingState"

	# Maintain the dash (no gravity during the burst).
	player.velocity = Vector2(dash_dir * player.config.dash_speed, 0.0)
	player.move_and_slide()
	return ""
