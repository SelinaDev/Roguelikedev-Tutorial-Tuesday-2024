class_name DirectionGetter
extends RefCounted

signal direction_selected

const DIRECTION_GETTER_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/DirectionGetter/direction_getter_info_container.tscn")

var _action: ActionWithDirection
var _device: int
var _info_panel: InfoPanel


func _init(player: Entity, action_name: String, action: ActionWithDirection) -> void:
	_action = action
	var player_info: PlayerInfo = PlayerComponent.get_player_info(player)
	_device = player_info.device
	var info_display: PlayerInfoDisplay = player_info.info_display
	_info_panel = info_display.spawn_panel(action_name, DIRECTION_GETTER_INFO_CONTAINER, player)
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)


func _on_event(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	for action: StringName in Globals.DIRECTION_MAPPING:
		if InputMap.event_is_action(event, action):
			accept(Globals.DIRECTION_MAPPING[action])
			return
	if event.is_action_pressed(&"back"):
		cancel()


func _cleanup() -> void:
	InputManager.pop_handle(_device)
	_info_panel.close()


func cancel() -> void:
	_cleanup()
	direction_selected.emit(null)


func accept(direction: Vector2i) -> void:
	_cleanup()
	_action.offset = direction
	direction_selected.emit(_action)
