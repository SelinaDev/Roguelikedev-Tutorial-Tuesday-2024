class_name HostileEnemyActorComponent
extends ActorComponent


func _enter_entity(_entity: Entity) -> void:
	SignalBus.group_took_turn.connect(_on_group_took_turn)


func _on_group_took_turn() -> void:
	print("The %s wonders when it will get to take a real turn." % _parent_entity.name.capitalize())
	_queued_action = WaitAction.new(_parent_entity)
