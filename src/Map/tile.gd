class_name Tile
extends Resource

@export var texture: AtlasTexture
@export var blocks_movement: bool = true
@export var blocks_sight: bool = true

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
