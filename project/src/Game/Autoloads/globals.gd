extends Node


var CELL_SIZE: Vector2i = ProjectSettings.get_setting("global/cell_size")
const CARDINAL_OFFSETS: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]
const ALL_OFFSETS: Array[Vector2i] = [
	Vector2i.RIGHT, 
	Vector2i.RIGHT + Vector2i.UP,
	Vector2i.UP,
	Vector2i.UP * Vector2i.LEFT,
	Vector2i.LEFT,
	Vector2i.LEFT + Vector2i.DOWN,
	Vector2i.DOWN,
	Vector2i.DOWN + Vector2i.RIGHT
]

const DIRECTION_MAPPING = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
}
