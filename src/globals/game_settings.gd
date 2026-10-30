extends SettingsManager
## 2D sidescroller settings autoload (registered as "GameSettings").
##
## Inherits all persistence/apply logic from SettingsManager (addons/settings_kit).
## It supplies this game's rebindable action list AND registers default key bindings
## for the controller's actions at startup — before the base _ready() runs
## load_keybinds() — so saved rebinds load correctly and the controller works out of
## the box. (The controller also self-provisions these as a fallback.)

## Default key bindings: action -> physical keycodes.
const DEFAULT_BINDINGS := {
	"left": [KEY_A, KEY_LEFT],
	"right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE, KEY_W, KEY_UP],
	"dash": [KEY_L],
	"sprint": [KEY_SHIFT],
	"crouch": [KEY_S, KEY_DOWN],
	"interact": [KEY_E],
	"walk_run_toggle": [KEY_CAPSLOCK],
	"pause": [KEY_ESCAPE],
}

## Actions exposed in the rebind UI and persisted.
const REBINDABLE: Array[String] = [
	"left", "right", "jump", "dash", "sprint", "crouch", "interact", "walk_run_toggle",
]


func _ready() -> void:
	_provision_default_actions()
	rebindable_actions = REBINDABLE
	super()


## Create each action with its default binding if the project hasn't defined it,
## so the InputMap is populated before load_keybinds() runs.
func _provision_default_actions() -> void:
	for action in DEFAULT_BINDINGS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for kc in DEFAULT_BINDINGS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = kc
			InputMap.action_add_event(action, ev)
