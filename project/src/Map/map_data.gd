class_name MapData
extends Resource

const BLOCKING_ENTITIY_PATHFIND_WEIGHT = 5

@export var id: int
@export var entities: Array[Entity]
@export var tiles: Dictionary # Dictionary[Vector2i, Tile]
@export var size: Vector2i
@export var region_name: String = ""


var canvas: RID
var total_fov: Dictionary = {}
var fovs: Dictionary = {}
var pathfinder: AStarGrid2D


func set_fov(index: int, new_fov: Dictionary) -> void:
	fovs[index] = new_fov
	_update_total_fov()


func clear_fov(index: int) -> void:
	fovs.erase(index)
	_update_total_fov()


func force_fov_update() -> void:
	for entity: Entity in get_entities([Component.Type.Fov, Component.Type.Position]): 
		entity.process_message(Message.new("fov_update"))


func is_in_fov(position: Vector2i, index: int = -1) -> bool:
	var target_fov: Dictionary = total_fov
	if index != -1:
		target_fov = fovs.get(index, {})
	return target_fov.get(position, false) 


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


func get_entities_at(position: Vector2i) -> Array[Entity]:
	return get_entities([Component.Type.Position]).filter(
		func(entity: Entity) -> bool: return PositionComponent.get_entity_position(entity) == position
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
	entity.process_message(Message.new("enter_map", {"canvas": canvas}))


func remove_entity(entity: Entity) -> void:
	entities.erase(entity)
	entity.map_data = null
	entity.process_message(Message.new("exit_map"))


func activate() -> void:
	setup_pathfinder()
	canvas = RenderingServer.canvas_create()
	_render_tiles()
	_render_entities()


func setup_pathfinder() -> void:
	pathfinder = AStarGrid2D.new()
	pathfinder.region = Rect2i(Vector2i.ZERO, size)
	pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinder.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	pathfinder.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	pathfinder.update()
	for tile_position: Vector2i in tiles:
		var tile: Tile = tiles[tile_position]
		pathfinder.set_point_solid(tile_position, tile.blocks_movement)
	for entity: Entity in get_entities([Component.Type.Position, Component.Type.MovementBlocker]):
		var entity_position: Vector2i = (entity.get_component(Component.Type.Position) as PositionComponent).position
		pathfinder.set_point_weight_scale(entity_position, BLOCKING_ENTITIY_PATHFIND_WEIGHT)


func pathfinder_set_point(point: Vector2i, blocked: bool) -> void:
	if not pathfinder:
		return
	var weight := BLOCKING_ENTITIY_PATHFIND_WEIGHT if blocked else 0
	pathfinder.set_point_weight_scale(point, weight)
