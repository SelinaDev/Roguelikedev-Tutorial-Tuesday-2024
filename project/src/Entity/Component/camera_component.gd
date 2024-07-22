class_name CameraComponent
extends Component

var camera_state: PlayerCameraState


func process_message_execute(message: Message) -> void:
	match message.type:
		"render":
			if not camera_state:
				return
			if message.data.has("canvas"):
				camera_state.change_canvas(message.data.get("canvas"))
			if message.data.has("position"):
				camera_state.grid_position = message.data.get("position")
		"move":
			camera_state.grid_position = message.data.get("destination")
		"set_camera_state":
			camera_state = message.data.get("camera_state")
			camera_state.grid_position = message.data.get("position")
		"zoom_in":
			camera_state.zoom *= 2
		"zoom_out":
			camera_state.zoom /= 2


func get_component_type() -> Type:
	return Type.Camera
