class_name Entity
extends Resource

const TEMP_PLAYER_ICON: AtlasTexture = preload("res://src/Entity/temp_player_icon.tres")

var position: Vector2i
var canvas_item: RID
var device: int

# TEMPORARY (move into Actor later)
var action: Action = null

func initialize(device: int, canvas: RID, start_position) -> void:
	self.device = device
	InputManager.obtain_input_handle(device).received_input.connect(_on_event)
	draw(canvas)
	move(start_position)


func process_message(message: Message) -> void:
	_process_message_precalculate(message)
	_process_message_execute(message)

# Maybe move this into components
func _process_message_precalculate(message: Message) -> void:
	pass


func _process_message_execute(message: Message) -> void:
	match message.type:
		"move":
			move(message.data.get("offset", Vector2i.ZERO))


func draw(canvas: RID) -> void:
	canvas_item = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(canvas_item, canvas)
	RenderingServer.canvas_item_add_texture_rect_region(
		canvas_item,
		Rect2(Vector2.ZERO, Vector2(12, 12)),
		TEMP_PLAYER_ICON.atlas.get_rid(),
		TEMP_PLAYER_ICON.region,
	)
	move(position)


func move(offset: Vector2i) -> void:
	position += offset
	var transform := Transform2D().translated(Vector2(position * 12))
	RenderingServer.canvas_item_set_transform(canvas_item, transform)


func _on_event(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event.is_action_pressed("move_left"):
		action = MovementAction.new(self, Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		action = MovementAction.new(self, Vector2i.RIGHT)
	elif event.is_action_pressed("move_up"):
		action = MovementAction.new(self, Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		action = MovementAction.new(self, Vector2i.DOWN)


# TEMPORARY (move into Actor later)
func get_action() -> Action:
	var current_action: Action = action
	action = null
	return current_action
