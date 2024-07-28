class_name PlayerComponent
extends Component

var player_info: PlayerInfo:
	set(value):
		player_info = value
		player_index = player_info.player_index
@export_storage var player_index: int


func process_message_precalculate(message: Message) -> void:
	match message.type:
		"fov_update":
			message.data["index"] = player_info.player_index


func get_component_type() -> Type:
	return Type.Player


static func get_player_index(entity: Entity) -> int:
	var player_component: PlayerComponent = entity.get_component(Component.Type.Player)
	if not player_component:
		return -1
	return player_component.player_index


static func get_player_info(entity: Entity) -> PlayerInfo:
	var player_component: PlayerComponent = entity.get_component(Component.Type.Player)
	if not player_component:
		return null
	return player_component.player_info
