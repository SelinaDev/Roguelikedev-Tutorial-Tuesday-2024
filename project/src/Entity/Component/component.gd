class_name Component
extends Resource

enum Type {
	None,
	Actor,
	Camera,
	DirectController,
	Door,
	Drawable,
	Durability,
	Faction,
	Fov,
	Inventory,
	Item,
	Level,
	MovementBlocker,
	Player,
	Position,
	Power,
	Rememberable,
	Resistance,
	Stairs,
	StatusEffects,
	Use,
	VisibilityBlocker,
	XP
}

var _parent_entity: Entity:
	set(value):
		_parent_entity_ref = weakref(value)
	get:
		return _parent_entity_ref.get_ref() as Entity
var _parent_entity_ref: WeakRef = weakref(null)
var type: get = get_component_type


func set_parent_entity(entity: Entity) -> void:
	_parent_entity = entity


func get_component_type() -> Type:
	push_error("get_component_type() not implemented properly, called virtual base function!")
	return Type.None


func before_enter(_previous_component: Component) -> void:
	pass


func enter_entity(entity: Entity) -> void:
	_parent_entity = entity
	_enter_entity(entity)


func _enter_entity(_entity: Entity) -> void:
	pass


func reactivate() -> void:
	pass


func deactivate() -> void:
	pass


func before_exit() -> void:
	pass


func process_message_precalculate(_message: Message) -> void:
	pass


func process_message_execute(_message: Message) -> void:
	pass
