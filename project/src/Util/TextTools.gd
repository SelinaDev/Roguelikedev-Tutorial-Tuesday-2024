class_name TextTools
extends RefCounted


static func concatenate_list(list: Array[String]) -> String:
	match list.size():
		0:
			return ""
		1:
			return list[0]
		2:
			return "%s and %s" % list
		_:
			return "%s, and %s" % [", ".join(list.slice(0, -1)), list.back()]
