class_name Scheduler
extends Node

var _num_players: int = 0
var _num_player_turns: int = 0


func _ready() -> void:
	set_process(false)


func start(players: Array[PlayerInfo]) -> void:
	set_process(true)
	for player: PlayerInfo in players:
		var player_entity: Entity = player.player_entity
		(player_entity.get_component(Component.Type.Actor) as ActorComponent).took_turn.connect(_on_player_took_turn)
	_num_players = players.size()


func _process(_delta: float) -> void:
	var active_maps := WorldManager.get_active_maps()
	var actors: Array[ActorComponent] = []
	for active_map: MapData in active_maps:
		actors.append_array(
			active_map.get_entities([Component.Type.Actor]).map(
				func(entity: Entity) -> ActorComponent: return entity.get_component(Component.Type.Actor)
			)
		)
	for actor: ActorComponent in actors:
		var action: Action = actor.get_action()
		if action:
			actor.receive_action_result(action.perform())


func _on_player_took_turn(player_entity: Entity) -> void:
	SignalBus.player_took_turn.emit(player_entity)
	_num_player_turns += 1
	if _num_player_turns >= _num_players:
		_num_player_turns = 0
		SignalBus.group_took_turn.emit()
