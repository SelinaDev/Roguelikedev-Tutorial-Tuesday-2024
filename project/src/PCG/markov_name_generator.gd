class_name MarkovNameGenerator
extends RefCounted

const MAX_TRIES := 20

var order_1: Dictionary
var order_2: Dictionary

var _rng := RandomNumberGenerator.new()


func initialize(source: String) -> void:
	_rng.randomize()
	var source_names := source.split("\n", false)
	_build_order_1(source_names)
	_build_order_2(source_names)


func generate_name() -> String:
	return _generate_name()


func generate_name_with_length(min_length: int, max_length: int) -> String:
	var tries := 0
	while true:
		var proposal := _generate_name()
		if (proposal.length() >= min_length and proposal.length() <= max_length) or tries >= MAX_TRIES:
			return proposal
		else:
			tries += 1
	return ""


func _generate_name() -> String:
	var proposal := ""
	var next_letter := "_"
	while next_letter != "":
		next_letter = _get_next_letter(proposal)
		proposal += next_letter
	return proposal


func _get_next_letter(previous: String) -> String:
	var tuple: Array = order_2.get(previous.right(2),
		order_1.get(previous.right(1), [[""], [1]])
	)
	return tuple[0][_rng.rand_weighted(tuple[1])]


func _build_order_1(source_strings: PackedStringArray) -> void:
	var probabilities := {}
	for name: String in source_strings:
		var previous := ""
		for c: String in name.strip_edges().to_lower().split("", false):
			if not previous in probabilities:
				probabilities[previous] = {}
			probabilities[previous][c] = probabilities[previous].get(c, 0) + 1
			previous = c
		if not previous in probabilities:
			probabilities[previous] = {}
		probabilities[previous][""] = probabilities[previous].get("", 0) + 1
	order_1 = _build_from_probabilities(probabilities)


func _build_order_2(source_strings: PackedStringArray) -> void:
	var probabilities := {}
	for name: String in source_strings:
		var bigrams := name.strip_edges().to_lower().bigrams()
		var previous := bigrams[0]
		for b: String in bigrams.slice(1):
			if not previous in probabilities:
				probabilities[previous] = {}
			var next := b[1]
			probabilities[previous][next] = probabilities[previous].get(next, 0) + 1
			previous = b
		if not previous in probabilities:
			probabilities[previous] = {}
		probabilities[previous][""] = probabilities[previous].get("", 0) + 1
	order_2 = _build_from_probabilities(probabilities)


func _build_from_probabilities(probabilities: Dictionary) -> Dictionary:
	var model := {}
	for letter: String in probabilities:
		var letter_array := []
		var weight_array := []
		for next_letter: String in probabilities[letter]:
			letter_array.append(next_letter)
			weight_array.append(probabilities[letter][next_letter])
		model[letter] = [letter_array, weight_array]
	return model
