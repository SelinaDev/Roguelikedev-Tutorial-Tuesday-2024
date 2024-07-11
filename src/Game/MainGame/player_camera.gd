class_name PlayerCamera
extends Node

var cell_size: Vector2i = ProjectSettings.get_setting("global/cell_size")
var container: SubViewportContainer
var canvas: RID:
	set(value):
		canvas = value
		_update()
var viewport: RID
var viewport_size: Vector2:
	set(value): 
		viewport_size = value
		_update()
var grid_position: Vector2i:
	set(value):
		grid_position = value
		_update()

func _ready() -> void:
	var container = get_parent()
	await container.ready
	container.resized.connect(_on_resize)
	_on_resize()


func _on_resize() -> void:
	viewport_size = container.get_rect().size


func _update() -> void:
	if not (canvas.is_valid() and viewport.is_valid()):
		return
	var target_position := Vector2(grid_position * cell_size + cell_size / 2)
	var center_offset: Vector2 = viewport_size / 2
	var transform := Transform2D().translated(center_offset - target_position)
	RenderingServer.viewport_set_canvas_transform(viewport, canvas, transform)
