class_name DrawableComponent
extends Component

enum RenderOrder {
	MAP_OBJECT,
	CORPSE,
	ITEM,
	ACTOR,
	EFFECT,
}

@export var texture: AtlasTexture
@export var render_order: RenderOrder = RenderOrder.ITEM


var _target_canvas: RID
var _canvas_item: RID


func _enter_entity(_entity: Entity) -> void:
	_configure_visuals()


func before_exit() -> void:
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_clear(_canvas_item)


func process_message_precalculate(message: Message) -> void:
	match message.type:
		"visual_update":
			texture = message.data.get("texture", texture)
			render_order = message.data.get("render_order", render_order)
			_configure_visuals()
		"position_update":
			assert(message.data.has("position"))
			_configure_position(message.data.get("position"))
		"render":
			if message.data.has("canvas"):
				set_target_canvas(message.data.get("canvas"))
			if message.data.has("position"):
				_configure_visuals()
				_configure_position(message.data.get("position"))
		"set_canvas":
			assert(message.data.has("canvas"))
			set_target_canvas(message.data.get("canvas"))


func _configure_position(position: Vector2i) -> void:
	if not _canvas_item.is_valid():
		return
	var cell_size: Vector2i = ProjectSettings.get_setting("global/cell_size")
	var transform := Transform2D().translated(Vector2(position * cell_size))
	RenderingServer.canvas_item_set_transform(_canvas_item, transform)


func _configure_visuals() -> void:
	var cell_size: Vector2i = ProjectSettings.get_setting("global/cell_size")
	if not _canvas_item.is_valid():
		_canvas_item = RenderingServer.canvas_item_create()
	else:
		RenderingServer.canvas_item_clear(_canvas_item)
	RenderingServer.canvas_item_add_texture_rect_region(
		_canvas_item,
		Rect2(Vector2.ZERO, Vector2(cell_size)),
		texture.atlas.get_rid(),
		texture.region
	)
	RenderingServer.canvas_item_set_z_index(_canvas_item, render_order)
	#if _target_canvas.is_valid():
		#RenderingServer.canvas_item_set_parent(_canvas_item, _target_canvas)


func set_target_canvas(canvas: RID) -> void:
	_target_canvas = canvas
	RenderingServer.canvas_item_set_parent(_canvas_item, _target_canvas)


func get_component_type() -> Type:
	return Component.Type.Drawable
