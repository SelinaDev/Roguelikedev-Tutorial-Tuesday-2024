class_name TileVariation
extends Resource

@export var tile_textures: Array[AtlasTexture]


func modify(tile: Tile, rng: RandomNumberGenerator) -> void:
	var random_texture: AtlasTexture = tile_textures[rng.randi() % tile_textures.size()]
	tile.texture = random_texture
