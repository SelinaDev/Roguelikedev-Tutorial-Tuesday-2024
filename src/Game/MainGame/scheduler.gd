class_name Scheduler
extends Node

var actors: Array = []


func _process(delta: float) -> void:
	for actor in actors:
		var action: Action = actor.get_action()
		if action:
			action.perform()
