class_name MapData
extends Resource

@export var id: int
@export var canvas: RID
@export var entities: Array[Entity]
@export var tiles: Dictionary # Dictionary[Vector2i, Tile]
@export var size: Vector2i
@export var region_name: String = ""

var total_fov: Dictionary = {}
var fovs: Dictionary = {}


func set_fov(index: int, new_fov: Dictionary) -> void:
	fovs[index] = new_fov
	_update_total_fov()


func clear_fov(index: int) -> void:
	fovs.erase(index)
	_update_total_fov()


func _update_total_fov() -> void:
	_recompute_total_fov()
	for drawable_entity: Entity in get_entities([Component.Type.Drawable, Component.Type.Position]):
		drawable_entity.process_message(Message.new(
			"fov_updated",
			{"fov": total_fov}
		))


func _recompute_total_fov() -> void:
	var old_total_fov: Dictionary = total_fov
	total_fov = {}
	for fov: Dictionary in fovs.values():
		total_fov.merge(fov)
	var disabled_tiles: Array = old_total_fov.keys().filter(
		func(position: Vector2i) -> bool: return not position in total_fov
	)
	var enabled_tiles: Array = total_fov.keys().filter(
		func(position: Vector2i) -> bool: return not position in old_total_fov
	)
	for disabled_tile: Vector2i in disabled_tiles:
		var tile: Tile = tiles.get(disabled_tile)
		if tile:
			tile.is_in_view = false
	for enabled_tile: Vector2i in enabled_tiles:
		var tile: Tile = tiles.get(enabled_tile)
		if tile:
			tile.is_in_view = true


func _render_tiles() -> void:
	assert(canvas.is_valid())
	for tile_position: Vector2i in tiles:
		var tile: Tile = tiles[tile_position]
		tile.render(canvas, tile_position)


func _render_entities() -> void:
	var renderable_entities: Array[Entity] = get_entities([Component.Type.Drawable, Component.Type.Position])
	for entity: Entity in renderable_entities:
		entity.process_message(Message.new("render", {"canvas": canvas}))


func _init(id: int, width: int, height: int, base_tile: Tile = null) -> void:
	self.id = id
	canvas = RenderingServer.canvas_create()
	tiles = {}
	size = Vector2i(width, height)
	for x: int in width:
		for y: int in height:
			var new_tile: Tile = null if base_tile == null else base_tile.duplicate()
			tiles[Vector2i(x, y)] = new_tile


func get_entities(types: Array[Component.Type]) -> Array[Entity]:
	return entities.filter(
		func(entity: Entity) -> bool: return types.all(
			func(type: Component.Type) -> bool: return  entity.has_component(type)
		)
	)


func get_blocking_entity_at(position: Vector2i) -> Entity:
	var entities := get_entities([Component.Type.Position, Component.Type.MovementBlocker]).filter(
		func(entity: Entity) -> bool:
			return (entity.get_component(Component.Type.Position) as PositionComponent).position == position
	)
	if entities.is_empty():
		return null
	return entities.front()


func enter_entity(entity: Entity) -> void:
	entities.append(entity)
	entity.map_data = self


func activate() -> void:
	canvas = RenderingServer.canvas_create()
	_render_tiles()
	_render_entities()
