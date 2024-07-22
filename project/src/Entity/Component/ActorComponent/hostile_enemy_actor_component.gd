class_name HostileEnemyActorComponent
extends ActorComponent

@export var ai_components: Array[AiComponent]


func _enter_entity(_entity: Entity) -> void:
	SignalBus.group_took_turn.connect(_on_group_took_turn)


func _on_group_took_turn() -> void:
#	print("The %s wonders when it will get to take a real turn." % _parent_entity.name.capitalize())
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
			# TODO: switch this to a targeted player
			var player_entity: Entity = _parent_entity.map_data.get_entities([Component.Type.Player]).front()
			for ai_component: AiComponent in ai_components:
				message.get_array("proposed_actions").append(ai_component.get_proposed_actions(_parent_entity, player_entity))


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
