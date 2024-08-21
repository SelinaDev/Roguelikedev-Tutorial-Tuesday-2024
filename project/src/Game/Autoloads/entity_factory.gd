extends Node

var ENTITY_DB = preload("res://resources/ResourceDBs/Entity_db.tres")


func get_entity(key: String) -> Entity:
	var entity: Entity = ENTITY_DB.entries.get(key)
	if entity:
		entity = entity.reify()
	return entity
