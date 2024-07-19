class_name ActionWithDirection
extends Action

var offset: Vector2i


func _init(performing_entity: Entity, offset: Vector2i) -> void:
	super(performing_entity)
	self.offset = offset


func get_destination() -> Vector2i:
	var destination := offset
	var position_component: PositionComponent = _performing_entity.get_component(Component.Type.Position)
	if position_component:
		destination += position_component.position
	return destination


func get_blocking_entity_at_destination() -> Entity:
	return _performing_entity.map_data.get_blocking_entity_at(get_destination())
