class_name DrawableComponent
extends Component

enum RenderOrder {
	MAP_OBJECT,
	CORPSE,
	ITEM,
	ACTOR,
	EFFECT,
	UI
}

@export var texture: AtlasTexture:
	set = set_texture
@export var render_order: RenderOrder = RenderOrder.ITEM:
	set = set_render_order
@export_color_no_alpha var color: Color = Color.WHITE:
	set = set_color
@export var modulate: Color = Color.WHITE:
	set = set_modulate
@export var visible: bool = true:
	set = set_visible
@export var position: Vector2i:
	set = set_position

@export var drawable_effects: Array[DrawableEffect]
@export var _active_drawable_effects: Dictionary

var _target_canvas: RID
var _canvas_item: RID
var _transform: Transform2D = Transform2D()

func _enter_entity(_entity: Entity) -> void:
	for drawable_effect: DrawableEffect in drawable_effects:
		add_drawable_effect(drawable_effect)
	_full_update()


func before_exit() -> void:
	for effect: DrawableEffect in _active_drawable_effects:
		effect.stop()
	_active_drawable_effects = {}
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_clear(_canvas_item)


func add_drawable_effect(effect: DrawableEffect) -> void:
	var previous_effect: DrawableEffect = _active_drawable_effects.get(effect)
	if previous_effect:
		previous_effect.stop()
	_active_drawable_effects[effect.get_effect_type()] = effect
	effect.start(self)


func _on_drawable_effect_finished(effect: DrawableEffect) -> void:
	_active_drawable_effects.erase(effect.get_effect_type())


func process_message_execute(message: Message) -> void:
	match message.type:
		"visual_update":
			render_order = message.data.get("render_order", render_order)
			texture = message.data.get("texture", texture)
		"position_update":
			assert(message.data.has("position"))
			position = message.data.get("position")
		"render":
			if message.data.has("canvas"):
				set_target_canvas(message.data.get("canvas"))
			if message.data.has("position"):
				position = message.data.get("position")
				_full_update()
		"set_canvas":
			assert(message.data.has("canvas"))
			set_target_canvas(message.data.get("canvas"))
		"clear_visuals":
			clear()
		"fov_updated":
			_handle_fov_updated(message)
		"set_visibility":
			var visible: bool = message.data.get("visible", true)
			RenderingServer.canvas_item_set_visible(_canvas_item, visible)


func clear() -> void:
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_clear(_canvas_item)
		_canvas_item = RID()
	for effect: DrawableEffect in drawable_effects:
		effect.stop()
	_active_drawable_effects = {}


func _handle_fov_updated(message: Message) -> void:
	assert(message.data.has("fov"))
	assert(message.data.has("position"))
	var can_remember: bool = false
	var remember_color: Color
	if message.data.has("remember"):
		can_remember = true
		remember_color = message.data.get("remember")
	var in_fov: bool = message.data.get("fov").get(message.data.get("position"), false)
	var explored: bool = (_parent_entity.map_data.tiles[message.data.get("position")] as Tile).is_explored
	_set_fov_visibility(in_fov, explored, can_remember, remember_color)


func _set_fov_visibility(in_fov: bool, explored: bool, can_remember: bool, remember_color: Color) -> void:
	if not can_remember:
		visible = in_fov
	else:
		visible = explored
		modulate = Color.WHITE if in_fov else remember_color


func _configure_position(position: Vector2i) -> void:
	if not _canvas_item.is_valid():
		return
	var cell_size: Vector2i = ProjectSettings.get_setting("global/cell_size")
	var transform := Transform2D().translated(Vector2(position * cell_size))
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_set_transform(_canvas_item, transform)


func set_texture(new_texture: AtlasTexture) -> void:
	texture = new_texture
	_full_update()


func set_render_order(new_render_order: RenderOrder) -> void:
	render_order = new_render_order
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_set_z_index(_canvas_item, render_order)


func set_color(new_color: Color) -> void:
	color = new_color
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_set_self_modulate(_canvas_item, color)


func set_modulate(new_modulate: Color) -> void:
	modulate = new_modulate
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_set_modulate(_canvas_item, modulate)


func set_visible(new_visibility: bool) -> void:
	visible = new_visibility
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_set_visible(_canvas_item, visible)


func set_position(new_position: Vector2i) -> void:
	position = new_position
	if not _canvas_item.is_valid():
		return
	var cell_size: Vector2i = ProjectSettings.get_setting("global/cell_size")
	_transform = Transform2D().translated(Vector2(position * cell_size))
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_set_transform(_canvas_item, _transform)


func _full_update() -> void:
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
	RenderingServer.canvas_item_set_visible(_canvas_item, visible)
	RenderingServer.canvas_item_set_transform(_canvas_item, _transform)
	RenderingServer.canvas_item_set_self_modulate(_canvas_item, color)
	RenderingServer.canvas_item_set_modulate(_canvas_item, modulate)
	if _target_canvas.is_valid():
		RenderingServer.canvas_item_set_parent(_canvas_item, _target_canvas)


func set_target_canvas(canvas: RID) -> void:
	_target_canvas = canvas
	if _canvas_item.is_valid():
		RenderingServer.canvas_item_set_parent(_canvas_item, _target_canvas)


func get_component_type() -> Type:
	return Component.Type.Drawable
