class_name HostileEnemyActorComponent
extends ActorComponent

@export var ai_components: Array[AiComponent]
@export var turn_syncher: TurnSyncher


func _enter_entity(_entity: Entity) -> void:
	var duplicated_components: Array[AiComponent] = []
	for ai_component: AiComponent in ai_components:
		duplicated_components.append(ai_component.duplicate(true))
	ai_components = duplicated_components
	turn_syncher = TurnSyncher.new()


func reactivate() -> void:
	turn_syncher.setup(_parent_entity)
	if not SignalBus.group_took_turn.is_connected(_on_group_took_turn):
		SignalBus.group_took_turn.connect(_on_group_took_turn)
	if not SignalBus.player_took_turn.is_connected(_on_player_took_turn):
		SignalBus.player_took_turn.connect(_on_player_took_turn)


func _on_group_took_turn() -> void:
	if turn_syncher.check_group_turn():
		_take_turn()


func _on_player_took_turn(player: Entity) -> void:
	if turn_syncher.check_player_turn(player):
		_take_turn()


func _take_turn() -> void:
	_parent_entity.process_message(Message.new(
		"get_action",
		{"proposed_actions": [
			ProposedAction.new().with_priority(ProposedAction.Priority.FALLBACK).with_action(WaitAction.new(_parent_entity))
		]}
	))


func process_message_precalculate(message: Message) -> void:
	match message.type:
		"get_action":
			var player_entity: Entity = turn_syncher.get_synched_player()
			for ai_component: AiComponent in ai_components:
				message.get_array("proposed_actions").append_array(ai_component.get_proposed_actions(_parent_entity, player_entity))


func process_message_execute(message: Message) -> void:
	match message.type:
		"get_action":
			var proposed_actions := message.get_array("proposed_actions")
			var proposed_action: ProposedAction = proposed_actions.reduce(
				func(action: ProposedAction, tested_action: ProposedAction) -> ProposedAction:
					if tested_action.priority > action.priority:
						return tested_action
					elif tested_action.priority < action.priority:
						return action
					return tested_action if tested_action.score > action.score else action
			)
			_queued_action = proposed_action.action
		"enter_map":
			turn_syncher.setup(_parent_entity)
			SignalBus.group_took_turn.connect(_on_group_took_turn)
			SignalBus.player_took_turn.connect(_on_player_took_turn)
