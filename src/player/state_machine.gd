extends Node
class_name StateMachine

@export_node_path("State") var initial_state_path: NodePath

var current_state: State
var states: Dictionary = {}

func _ready():
	# Wait for owner to be ready
	await owner.ready

	# Initialize all states
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.player = owner

	# Set initial state from path
	if initial_state_path:
		var initial_state = get_node(initial_state_path)
		if initial_state and initial_state is State:
			current_state = initial_state
			current_state.enter()
			print("Initial state: ", get_current_state_name())

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event):
	if current_state:
		current_state.handle_input(event)

func transition_to(state_name: String):
	var new_state = states.get(state_name.to_lower())

	if new_state == null:
		push_error("State " + state_name + " does not exist")
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	print(get_current_state_name())
	current_state.enter()

func get_current_state_name() -> String:
	if current_state:
		return current_state.name
	return ""
