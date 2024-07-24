class_name InfoContainer
extends MarginContainer

signal closed

var _player


func setup(player: Entity) -> void:
	_player = player
	_setup()


func _setup() -> void:
	pass


func close() -> void:
	closed.emit()
	_close()


func _close() -> void:
	pass
