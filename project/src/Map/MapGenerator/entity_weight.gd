class_name WeightedEntity
extends Resource

@export var entity_key: String
@export var weight: int


static func get_weighted_array(weighted_entities: Array[WeightedEntity]) -> Dictionary:
	var entities := []
	var weights := []
	
	for entity: WeightedEntity in weighted_entities:
		entities.append(entity.entity_key)
		weights.append(entity.weight)
	
	return {"entity_keys": entities, "weights": weights}
