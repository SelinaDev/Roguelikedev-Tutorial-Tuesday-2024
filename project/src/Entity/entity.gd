class_name Entity
extends Resource

@export var name: String
@export var is_proper_name: bool = false
@export var templates: Array[EntityTemplate]
@export var initial_components: Array[Component]

@export_storage var _components: Dictionary
var map_data: MapData:
	get:
		return _map_data_ref.get_ref() as MapData
	set(value):
		_map_data_ref = weakref(value)
var _map_data_ref: WeakRef = weakref(null)

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


func reactivate(_map_data: MapData) -> void:
	map_data = _map_data
	for component: Component in _components.values():
		component.set_parent_entity(self)
		component.reactivate()


func deactivate() -> void:
	for component: Component in _components.values():
		component.deactivate()


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


func add_status_effect(effect: StatusEffect) -> void:
	if not has_component(Component.Type.StatusEffects):
		enter_component(StatusEffectsComponent.new())
	var effects_component: StatusEffectsComponent = get_component(Component.Type.StatusEffects)
	effects_component.add_effect(effect)


func get_entity_name(indefinite: bool = false) -> String:
	if is_proper_name:
		return name
	elif indefinite:
		if name.substr(0, 1).to_lower() in ["a", "e", "i", "o", "u"]:
			return "an " + name
		else:
			return "a " + name
	else:
		return "the " + name
