class_name Entity
extends Resource

@export var templates: Array[EntityTemplate]
@export var initial_components: Array[Component]

var _components: Dictionary
# TODO: MapData

var _message_queue: Array[Message]


func _reify() -> Entity:
	var reified_entity := self.duplicate()
	var used_components := {}
	for template: EntityTemplate in templates:
		used_components.merge(template.get_components(), true)
	for component: Component in initial_components:
		used_components.merge({component.type: component}, true)
	for component: Component in used_components:
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



#var position: Vector2i
#var canvas_item: RID
#var device: int

#func initialize(device: int, canvas: RID, start_position) -> void:
	#self.device = device
	#InputManager.obtain_input_handle(device).received_input.connect(_on_event)
	#draw(canvas)
	#move(start_position)
#
#func draw(canvas: RID) -> void:
	#canvas_item = RenderingServer.canvas_item_create()
	#RenderingServer.canvas_item_set_parent(canvas_item, canvas)
	#RenderingServer.canvas_item_add_texture_rect_region(
		#canvas_item,
		#Rect2(Vector2.ZERO, Vector2(12, 12)),
		#TEMP_PLAYER_ICON.atlas.get_rid(),
		#TEMP_PLAYER_ICON.region,
	#)
	#move(position)
#
#
#func move(offset: Vector2i) -> void:
	#position += offset
	#var transform := Transform2D().translated(Vector2(position * 12))
	#RenderingServer.canvas_item_set_transform(canvas_item, transform)
#
#
#func _on_event(event: InputEvent) -> void:
	#if event.is_echo():
		#return
	#
	#if event.is_action_pressed("move_left"):
		#action = MovementAction.new(self, Vector2i.LEFT)
	#elif event.is_action_pressed("move_right"):
		#action = MovementAction.new(self, Vector2i.RIGHT)
	#elif event.is_action_pressed("move_up"):
		#action = MovementAction.new(self, Vector2i.UP)
	#elif event.is_action_pressed("move_down"):
		#action = MovementAction.new(self, Vector2i.DOWN)
#
#
## TEMPORARY (move into Actor later)
#func get_action() -> Action:
	#var current_action: Action = action
	#action = null
	#return current_action
