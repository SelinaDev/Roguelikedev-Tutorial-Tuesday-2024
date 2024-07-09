class_name Message
extends RefCounted

var type: String
var data: Dictionary


func _init(type: String, data: Dictionary = {}) -> void:
	self.type = type
	self.data = data
