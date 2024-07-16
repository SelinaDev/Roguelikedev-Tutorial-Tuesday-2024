class_name Scheduler
extends Node

var actors: Array[ActorComponent] = []


func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	for actor: ActorComponent in actors:
		var action: Action = actor.get_action()
		if action:
			action.perform()
