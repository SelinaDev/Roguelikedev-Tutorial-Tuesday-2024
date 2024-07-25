class_name RememberableComponent
extends Component

@export_color_no_alpha var not_in_view_color := Color.WHITE


func process_message_precalculate(message: Message) -> void:
	match message.type:
		&"fov_updated":
			message.data[&"remember"] = not_in_view_color


func get_component_type() -> Type:
	return Type.Rememberable
