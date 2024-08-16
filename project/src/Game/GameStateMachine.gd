class_name GameStateMachine
extends Node

@export_file("*tscn") var initial_state: String

var _current_state: GameState


func _ready() -> void:
	_transition_to(initial_state)


func _transition_to(next_state_path: String, data: Dictionary = {}) -> void:
	if _current_state:
		_current_state.exit()
		_current_state.queue_free()
	get_tree().paused = false
	_current_state = (load(next_state_path) as PackedScene).instantiate()
	add_child(_current_state)
	_current_state.transition_requested.connect(_transition_to)
	_current_state.enter(data)
