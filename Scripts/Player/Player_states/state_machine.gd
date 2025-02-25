class_name StateMachine
extends Node

@export var CURRENT_STATE: State
var states: Dictionary = {}

func _ready():
	await owner.ready  # Ensure Player is fully loaded

	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)

			child.owner = owner  
			if owner is Player:
				child.PLAYER = owner as Player 
			else:
				print("ERROR: Owner is not a Player!")

	if CURRENT_STATE:
		CURRENT_STATE.enter()

func _process(delta):
	if CURRENT_STATE:
		CURRENT_STATE.update(delta)
	else:
		print("ERROR: CURRENT_STATE is NULL!")

func _physics_process(delta):
	if CURRENT_STATE:
		CURRENT_STATE.physics_update(delta)
	else:
		print("ERROR: CURRENT_STATE is NULL!")

func on_child_transition(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	if new_state != null and new_state != CURRENT_STATE:
		CURRENT_STATE.exit()
		new_state.enter()
		CURRENT_STATE = new_state
	else:
		push_warning("State does not exist: " + new_state_name)
