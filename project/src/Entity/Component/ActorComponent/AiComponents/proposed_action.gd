class_name ProposedAction
extends RefCounted

enum Priority {
	FALLBACK,
	LOW,
	MEDIUM,
	HIGH,
	FORCE
}

var priority: Priority = Priority.LOW
var score: int = 0
var action: Action


func with_priority(new_priority: Priority) -> ProposedAction:
	priority = new_priority
	return self


func with_score(new_score: int) -> ProposedAction:
	score = new_score
	return self


func with_action(new_action: Action) -> ProposedAction:
	action = new_action
	return self
