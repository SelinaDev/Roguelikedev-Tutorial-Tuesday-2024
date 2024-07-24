class_name DirectionGetter
extends RefCounted

signal direction_selected

var _action: ActionWithDirection
var _device: int


func _init(device: int, action: ActionWithDirection) -> void:
	_action = action
	_device = device
	InputManager.obtain_input_handle(device).received_input.connect(_on_event)


func _on_event(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	for action: StringName in Globals.DIRECTION_MAPPING:
		if event.is_action_pressed(action):
			accept(Globals.DIRECTION_MAPPING[action])
			return
	if event.is_action_pressed("back"):
		cancel()


func cancel() -> void:
	InputManager.pop_handle(_device)
	direction_selected.emit(null)


func accept(direction: Vector2i) -> void:
	InputManager.pop_handle(_device)
	_action.offset = direction
	direction_selected.emit(_action)
