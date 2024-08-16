class_name PlayerNameGenerator
extends RefCounted

const PATH_NAMES_NEUTRAL = "res://resources/PCG/Corpora/names_neutral.txt"
const PATH_DESCRIPTIONS = "res://resources/PCG/Corpora/descriptions.txt"
const MIN_NAME_LENGTH = 4
const MAX_NAME_LENGTH = 12
const MAX_NAME_LENGTH_TWO_NAMES = 8
const P_DOUBLE_NAME = 0.25
const P_BYNAME = 0.7


var _rng := RandomNumberGenerator.new()
var _markov_generator := MarkovNameGenerator.new()
var _descriptions: PackedStringArray



func initialize() -> void:
	_rng.randomize()
	_initialize_markov()
	_load_descriptions()


func _initialize_markov() -> void:
	var names_file := FileAccess.open(PATH_NAMES_NEUTRAL, FileAccess.READ)
	_markov_generator.initialize(names_file.get_as_text(true))


func _load_descriptions() -> void:
	var descriptions_file := FileAccess.open(PATH_DESCRIPTIONS, FileAccess.READ)
	_descriptions = descriptions_file.get_as_text(true).split("\n", false)


func get_name() -> String:
	var name: String
	if _rng.randf() < P_DOUBLE_NAME:
		name = _get_doble_name()
	else:
		name = _get_single_name()
	if _rng.randf() < P_BYNAME:
		name = _add_byname(name)
	return name


func _get_single_name() -> String:
	return _markov_generator.generate_name_with_length(MIN_NAME_LENGTH, MAX_NAME_LENGTH).capitalize()


func _get_doble_name() -> String:
	return _markov_generator.generate_name_with_length(MIN_NAME_LENGTH, MAX_NAME_LENGTH_TWO_NAMES).capitalize() \
	+ " " \
	+ _markov_generator.generate_name_with_length(MIN_NAME_LENGTH, MAX_NAME_LENGTH_TWO_NAMES).capitalize()


func _add_byname(name: String) -> String:
	return "%s, the %s" % [
		name,
		_descriptions[_rng.randi() % _descriptions.size()].capitalize()
	]
