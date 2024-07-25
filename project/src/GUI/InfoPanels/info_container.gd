class_name InfoContainer
extends MarginContainer

signal closed

var _player: Entity
var _device: int


func setup(player: Entity) -> void:
	_player = player
	var player_component: PlayerComponent = _player.get_component(Component.Type.Player)
	_device = player_component.player_info.device
	_setup()


func _setup() -> void:
	pass


func close() -> void:
	closed.emit()
	_close()


func _close() -> void:
	pass


func get_control_hint_text() -> String:
	if _device == -1:
		return _get_control_hint_text_keyboard()
	else:
		return _get_control_hint_text_controller()


func _get_control_hint_text_controller() -> String:
	return ""


func _get_control_hint_text_keyboard() -> String:
	return ""
