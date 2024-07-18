class_name PlayerCameraState
extends RefCounted

signal state_discarded
signal state_changed
signal canvas_changed(new_canvas)


var grid_position: Vector2i:
	set(value):
		grid_position = value
		state_changed.emit()
var zoom: int = 2:
	set(value):
		zoom = max(1, value)
		state_changed.emit()


func _init(initial_position: Vector2i) -> void:
	grid_position = initial_position


func change_canvas(canvas: RID) -> void:
	canvas_changed.emit(canvas)


func discard() -> void:
	state_discarded.emit()
