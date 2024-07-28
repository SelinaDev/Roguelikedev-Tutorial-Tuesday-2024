class_name Message
extends RefCounted

var type: String
var data: Dictionary


func _init(type: String, data: Dictionary = {}) -> void:
	self.type = type
	self.data = data


func get_calculation(key: String) -> MessageCalculation:
	if not data.has(key):
		data[key] = MessageCalculation.new()
	assert(data[key] is MessageCalculation, "Tried to access non-calculation key as calculation in Message.")
	return data[key]


func get_array(key: String) -> Array:
	if not data.has(key):
		data[key] = []
	assert(data[key] is Array)
	return data[key]
