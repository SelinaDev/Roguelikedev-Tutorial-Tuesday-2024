class_name MapConfig
extends Resource

enum MapType {
	DUNGEON,
}

@export var map_width: int = 100
@export var map_height: int = 100
@export var max_rooms: int = 20
@export var max_tries: int = 1000
@export var max_enemies_per_room: int = 2
@export var max_items_per_room: int = 1
@export var floor_variation: TileVariation
@export var wall_variation: TileVariation
@export var map_type: MapType = MapType.DUNGEON
@export var room_pack: String = "dungeon"
var stairs_down: bool
var stairs_up: bool
