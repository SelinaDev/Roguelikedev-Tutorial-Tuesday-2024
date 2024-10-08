extends GameState

const MAIN_MENU = "res://src/Menus/MainMenu/main_menu.tscn"
const GAME_OVER_SCREEN = "res://src/Menus/GameOverScreen/game_over_screen.tscn"

@export var player_ui: Array[PlayerUiResource]
@onready var scheduler: Scheduler = $Scheduler

var _player_info: Array[PlayerInfo] = []


func enter(data: Dictionary = {}) -> void:
	SignalBus.exit_game.connect(_on_exit_game)
	SignalBus.player_died.connect(_on_player_died)
	_setup(data)


func _setup(data: Dictionary) -> void:
	_player_info = data.get("player_info")
	for i: int in player_ui.size():
		_fill_player_info(_player_info[i], i)
	
	for info: PlayerInfo in _player_info:
		_setup_player(info)
	scheduler.start(_player_info)
	
	if data.get("new", false):
		Log.send_log.bindv(["Welcome, adventurer%s!" % "s" if _player_info.size() > 1 else "", Log.COLOR_POSITIVE]).call_deferred()
	else:
		Log.send_log.bindv(["Welcome back, adventurer%s!" % "s" if _player_info.size() > 1 else "", Log.COLOR_POSITIVE]).call_deferred()


func _setup_player(player: PlayerInfo) -> void:
	var map_index: int = WorldManager.get_world().player_locations[player.player_index]
	var map: MapData = WorldManager.get_map(map_index)
	player.player_panel.setup(player.player_entity)
	RenderingServer.viewport_attach_canvas(player.sub_viewport.get_viewport_rid(), map.canvas)
	var player_camera = PlayerCamera.new(player)
	var player_actor_component: PlayerActorComponent = player.player_entity.get_component(Component.Type.Actor)
	player_actor_component.set_device(player.device)
	player.player_entity.process_message(Message.new(
		"set_camera_state",
		{"camera_state": player_camera.obtain_state()}
	))
	player.player_entity.process_message(Message.new("render", {"canvas": map.canvas}))


func _fill_player_info(info: PlayerInfo, player_index: int) -> void:
	var ui_info: PlayerUiResource = player_ui[player_index]
	info.sub_viewport = get_node(ui_info.viewport)
	info.player_panel = get_node(ui_info.player_panel)
	info.info_display = get_node(ui_info.player_info_display)


func _on_exit_game() -> void:
	var devices: Array = _player_info.map(func(info: PlayerInfo) -> int: return info.device)
	transition_requested.emit(MAIN_MENU, {"devices": devices})


func _on_player_died() -> void:
	var all_dead: bool = _player_info.map(
		func(info: PlayerInfo) -> Entity: return info.player_entity
	).all(
		func(e: Entity) -> bool: return not e.has_component(Component.Type.Durability)
	)
	if all_dead:
		transition_requested.emit(GAME_OVER_SCREEN, {"player_info": _player_info})
