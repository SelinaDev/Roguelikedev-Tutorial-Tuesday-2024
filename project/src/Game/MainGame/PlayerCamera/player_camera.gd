class_name PlayerCamera
extends RefCounted

var _cell_size: Vector2i = ProjectSettings.get_setting("global/cell_size")

var _viewport: SubViewport
var _viewport_size: Vector2

var _canvas: RID

var _camera_state_stack: Array[PlayerCameraState]


func _init(player_info: PlayerInfo) -> void:
	player_info.player_camera = self
	_viewport = player_info.sub_viewport
	_viewport_size = _viewport.get_visible_rect().size
	_viewport.size_changed.connect(_on_resize)
	


func obtain_state() -> PlayerCameraState:
	var start_position = Vector2i.ZERO
	var start_zoom: int = 2
	if not _camera_state_stack.is_empty():
		var current_state: PlayerCameraState = _camera_state_stack.back()
		current_state.state_changed.disconnect(_on_camera_state_changed)
		start_position = current_state.grid_position
		start_zoom = current_state.zoom
	var new_state := PlayerCameraState.new(start_position, start_zoom)
	new_state.state_changed.connect(_on_camera_state_changed)
	new_state.state_discarded.connect(_pop_state.bind(new_state))
	new_state.canvas_changed.connect(_set_canvas)
	_camera_state_stack.append(new_state)
	return new_state


func _pop_state(state: PlayerCameraState) -> void:
	assert(state == _camera_state_stack.back())
	_camera_state_stack.pop_back()
	if _camera_state_stack.is_empty():
		return
	var current_state: PlayerCameraState = _camera_state_stack.back()
	current_state.state_changed.connect(_on_camera_state_changed)
	_on_camera_state_changed()


func _on_camera_state_changed() -> void:
	var current_state: PlayerCameraState = _camera_state_stack.back()
	var grid_position: Vector2i = current_state.grid_position
	var zoom: int = current_state.zoom
	var target_position := Vector2(grid_position * _cell_size + _cell_size / 2)
	var center_offset: Vector2 = _viewport_size / 2
	var transform := Transform2D()\
		.scaled(Vector2i(zoom, zoom))\
		.translated(center_offset - target_position * zoom)
	if _viewport and _canvas.is_valid():
		RenderingServer.viewport_set_canvas_transform(_viewport.get_viewport_rid(), _canvas, transform)

func _set_canvas(canvas: RID) -> void:
	_canvas = canvas
	if not _camera_state_stack.is_empty():
		_on_camera_state_changed()


func _on_resize() -> void:
	_viewport_size = _viewport.size
	if not _camera_state_stack.is_empty():
		_on_camera_state_changed()
