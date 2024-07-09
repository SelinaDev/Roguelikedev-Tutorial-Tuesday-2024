# Singleton InputManager
extends Node

var _input_handles: Dictionary = {}

# Normally, Keyboard events are coded as device 0, but gamepads also start from 0.
# This function transforms the device to a distinguishable index.
static func get_device_index(event: InputEvent) -> int:
	if event is InputEventKey:
		return -1
	return event.device


func obtain_input_handle(device: int) -> InputHandle:
	var handle := InputHandle.new()
	if not _input_handles.has(device):
		_input_handles[device] = []
	_input_handles[device].append(handle)
	return handle


func pop_handle(device: int) -> void:
	_input_handles[device].pop_back()
	if _input_handles[device].is_empty():
		_input_handles.erase(device)


func _unhandled_input(event: InputEvent) -> void:
	var device: int = get_device_index(event)
	if _input_handles.has(device):
		_input_handles[device].back().received_input.emit(event)


func reset() -> void:
	_input_handles = {}


class InputHandle extends RefCounted:
	signal received_input(event)
