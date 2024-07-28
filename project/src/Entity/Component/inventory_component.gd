class_name InventoryComponent
extends Component


@export var capacity: int = 24
@export_storage var items: Array[Entity]


func drop(item: Entity) -> void:
	assert(item in items)
	items.erase(item)
	var parent_position := PositionComponent.get_entity_position(_parent_entity)
	item.place_at(parent_position)
	_parent_entity.map_data.enter_entity(item)


func get_component_type() -> Type:
	return Type.Inventory
