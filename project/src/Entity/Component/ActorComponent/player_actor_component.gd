class_name PlayerActorComponent
extends ActorComponent

var device: int


func set_device(new_device: int) -> void:
	device = new_device
	InputManager.obtain_input_handle(device).received_input.connect(_on_event)


func _on_event(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event.is_action_pressed("zoom_in"):
		_parent_entity.process_message(Message.new("zoom_in"))
	elif event.is_action_pressed("zoom_out"):
		_parent_entity.process_message(Message.new("zoom_out"))
	
	if event.is_action_pressed("move_left"):
		_queued_action = BumpAction.new(_parent_entity, Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		_queued_action = BumpAction.new(_parent_entity, Vector2i.RIGHT)
	elif event.is_action_pressed("move_up"):
		_queued_action = BumpAction.new(_parent_entity, Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		_queued_action = BumpAction.new(_parent_entity, Vector2i.DOWN)
	elif event.is_action_pressed("wait"):
		_queued_action = WaitAction.new(_parent_entity)
