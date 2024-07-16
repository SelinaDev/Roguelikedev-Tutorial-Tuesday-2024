class_name MapData
extends Resource

@export var id: int
@export var canvas: RID
@export var entities: Array[Entity]
@export var tiles: Dictionary # Dictionary[Vector2i, Tile]
@export var size: Vector2i
@export var region_name: String = ""


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


func activate() -> void:
	canvas = RenderingServer.canvas_create()
	_render_tiles()
	_render_entities()
