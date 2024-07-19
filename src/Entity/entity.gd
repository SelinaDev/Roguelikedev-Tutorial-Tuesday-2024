class_name Entity
extends Resource

@export var name: String
@export var templates: Array[EntityTemplate]
@export var initial_components: Array[Component]

var _components: Dictionary
var map_data: MapData:
	get:
		return _map_data_ref.get_ref() as MapData
	set(value):
		_map_data_ref = weakref(value)
var _map_data_ref: WeakRef

var _message_queue: Array[Message]


func reify() -> Entity:
	var reified_entity := self.duplicate()
	var used_components := {}
	for template: EntityTemplate in templates:
		used_components.merge(template.get_components(), true)
	for component: Component in initial_components:
		used_components.merge({component.type: component}, true)
	for component: Component in used_components.values():
		reified_entity.enter_component(component.duplicate())
	return reified_entity


func enter_component(component: Component) -> void:
	var previous_component: Component = get_component(component.type)
	component.before_enter(previous_component)
	if previous_component:
		previous_component.before_exit()
	_components[component.type] = component
	component.enter_entity(self)


func has_component(component_type: Component.Type) -> bool:
	return _components.has(component_type)


func get_component(component_type: Component.Type) -> Component:
	return _components.get(component_type, null)


func remove_component(component_type: Component.Type) -> Component:
	var component := get_component(component_type)
	_components.erase(component_type)
	return component


func place_at(position: Vector2i) -> Entity:
	var position_component := PositionComponent.new()
	enter_component(position_component)
	position_component.position = position
	return self


func process_message(message: Message) -> void:
	_message_queue.append(message)
	if _message_queue.size() > 1:
		return
	while(not _message_queue.is_empty()):
		for component: Component in _components.values():
			component.process_message_precalculate(_message_queue.front())
		for component: Component in _components.values():
			component.process_message_execute(_message_queue.front())
		_message_queue.pop_front()
