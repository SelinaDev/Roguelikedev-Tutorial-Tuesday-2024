class_name MessageCalculation
extends RefCounted


var base_value: int = 0
var terms: Array[int] = []
var factors: Array[float] = []


func get_result() -> int:
	var base_f: float = terms.reduce(
		func(accum: int, term: int) -> int: return accum + term,
		base_value
	)
	var result: float = factors.reduce(
		func(accum: float, factor: float) -> float: return accum * factor,
		base_f
	)
	return roundi(result)
