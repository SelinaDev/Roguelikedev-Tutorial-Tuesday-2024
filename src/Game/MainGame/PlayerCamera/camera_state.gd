class_name PlayerCameraState
extends RefCounted

signal state_discarded
signal grid_position_changed(new_position)
signal canvas_changed(new_canvas)


var grid_position: Vector2i:
	set(value):
		grid_position = value
		grid_position_changed.emit(grid_position)


func _init(initial_position: Vector2i) -> void:
	grid_position = initial_position


func change_canvas(canvas: RID) -> void:
	canvas_changed.emit(canvas)


func discard() -> void:
	state_discarded.emit()
