class_name Tile
extends Resource

const DARK_COLOR = Color.DARK_BLUE

@export var name: String
@export var texture: AtlasTexture
@export var blocks_movement: bool = true
@export var blocks_sight: bool = true
@export var is_explored: bool = false:
	set(value):
		if not is_explored:
			is_explored = value
		if is_explored and canvas_item.is_valid():
			RenderingServer.canvas_item_set_visible(canvas_item, true)
@export var is_in_view: bool = false: 
	set(value):
		if value == is_in_view:
			return
		is_in_view = value
		if is_in_view and not is_explored:
			is_explored = true
		if canvas_item.is_valid():
			RenderingServer.canvas_item_set_modulate(canvas_item, Color.WHITE if is_in_view else DARK_COLOR)

var canvas_item: RID


func render(canvas: RID, position: Vector2i) -> void:
	var cell_size: Vector2i = ProjectSettings.get_setting("global/cell_size")
	var render_pos := Vector2(position * cell_size)
	canvas_item = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_add_texture_rect_region(
		canvas_item, 
		Rect2(render_pos, Vector2(cell_size)), 
		texture.atlas.get_rid(), 
		texture.region
	)
	RenderingServer.canvas_item_set_parent(canvas_item, canvas)
	RenderingServer.canvas_item_set_z_index(canvas_item, -1)
	if not is_explored:
		RenderingServer.canvas_item_set_visible(canvas_item, false)
	else:
		RenderingServer.canvas_item_set_modulate(canvas_item, Color.WHITE if is_in_view else DARK_COLOR)
