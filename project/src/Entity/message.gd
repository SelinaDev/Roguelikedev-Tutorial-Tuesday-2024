class_name Message
extends RefCounted

var type: StringName
var data: Dictionary


func _init(type: StringName, data: Dictionary = {}) -> void:
	self.type = type
	self.data = data


func get_calculation(key: StringName) -> MessageCalculation:
	if not data.has(key):
		data[key] = MessageCalculation.new()
	assert(data[key] is MessageCalculation, "Tried to access non-calculation key as calculation in Message.")
	return data[key]


func get_array(key: StringName) -> Array:
	if not data.has(key):
		data[key] = []
	assert(data[key] is Array)
	return data[key]
