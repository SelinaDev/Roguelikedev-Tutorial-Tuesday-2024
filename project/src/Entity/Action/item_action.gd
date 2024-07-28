class_name ItemAction
extends Action

var _item: Entity


func _init(performing_entity: Entity, item: Entity) -> void:
	super(performing_entity)
	_item = item
