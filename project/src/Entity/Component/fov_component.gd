class_name FovComponent
extends Component

const multipliers = [
	[1, 0, 0, -1, -1, 0, 0, 1],
	[0, 1, -1, 0, 0, -1, 1, 0],
	[0, 1, 1, 0, 0, -1, -1, 0],
	[1, 0, 0, 1, -1, 0, 0, -1]
]

@export var base_radius: int = 8


var _fov: Dictionary

# TODO: FOV needs to be cleared when player changes to a new map

func process_message_precalculate(message: Message) -> void:
	match message.type:
		"fov_update":
			message.data.merge({"radius": base_radius}) # TODO: Maybe replace with a message data calculation


func process_message_execute(message: Message) -> void:
	match message.type:
		"position_update":
			_parent_entity.process_message(Message.new("fov_update"))
		"fov_update":
			assert(message.data.has("position"))
			assert(message.data.has("index"))
			_update_fov(
				_parent_entity.map_data,
				message.data.get("position"),
				message.data.get("radius")
			)
			_parent_entity.map_data.set_fov(message.data.get("index"), _fov)


func get_component_type() -> Type:
	return Type.Fov


func _update_fov(map_data: MapData, origin: Vector2i, radius: int) -> void:
	_clear_fov()
	var blocking_entities: Array = map_data.get_entities([Component.Type.Position, Component.Type.VisibilityBlocker]).map(
		func(entity: Entity) -> Vector2i: return (entity.get_component(Component.Type.Position) as PositionComponent).position
	)
	var blocked_positions := {}
	for blocking_entity: Vector2i in blocking_entities:
		blocked_positions[blocking_entity] = true
	_fov = {origin: true}
	for i in 8:
		_cast_light(map_data, blocked_positions, origin.x, origin.y, radius, 1, 1.0, 0.0, multipliers[0][i], multipliers[1][i], multipliers[2][i], multipliers[3][i])


func _clear_fov() -> void:
	_fov = {}


func _cast_light(map_data: MapData, blocked_positions: Dictionary, x: int, y: int, radius: int, row: int, start_slope: float, end_slope: float, xx: int, xy: int, yx: int, yy: int) -> void:
	if start_slope < end_slope:
		return
	var next_start_slope: float = start_slope
	for i in range(row, radius + 1):
		var blocked: bool = false
		var dy: int = -i
		for dx in range(-i, 1):
			var l_slope: float = (dx - 0.5) / (dy + 0.5)
			var r_slope: float = (dx + 0.5) / (dy - 0.5)
			if start_slope < r_slope:
				continue
			elif end_slope > l_slope:
				break
			var sax: int = dx * xx + dy * xy
			var say: int = dx * yx + dy * yy
			if ((sax < 0 and absi(sax) > x) or (say < 0 and absi(say) > y)):
				continue
			var ax: int = x + sax
			var ay: int = y + say
			#if ax >= map_data.size.x or ay >= map_data.size.y:
				#continue
			var radius2: int = radius * radius
			var position := Vector2i(ax, ay)
			var current_tile: Tile = map_data.tiles[position]
			if (dx * dx + dy * dy) < radius2:
				_fov[position] = true
			if blocked:
				if current_tile.blocks_sight or blocked_positions.get(position, false):
					next_start_slope = r_slope
					continue
				else:
					blocked = false
					start_slope = next_start_slope
			elif current_tile.blocks_sight or blocked_positions.get(position, false):
				blocked = true
				next_start_slope = r_slope
				_cast_light(map_data, blocked_positions, x, y, radius, i + 1, start_slope, l_slope, xx, xy, yx, yy)
		if blocked:
			break
