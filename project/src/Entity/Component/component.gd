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
	Fov,
	Inventory,
	Item,
	MovementBlocker,
	Player,
	Position,
	Power,
	Rememberable,
	Use,
	VisibilityBlocker
}

var _parent_entity: Entity:
	set(value):
		_parent_entity_ref = weakref(value)
	get:
		return _parent_entity_ref.get_ref() as Entity
var _parent_entity_ref: WeakRef = weakref(null)
var type: get = get_component_type


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


func before_exit() -> void:
	pass


func process_message_precalculate(_message: Message) -> void:
	pass


func process_message_execute(_message: Message) -> void:
	pass
