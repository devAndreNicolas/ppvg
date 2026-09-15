class_name ComboReader
extends RefCounted

const INPUT_WINDOW := 0.68
var inputs: Array[Dictionary] = []

func record(action: String, now: float) -> String:
	_prune(now)
	inputs.append({"action": action, "time": now})
	for combo: Dictionary in AttackCatalog.COMBOS:
		var sequence: Array = combo.sequence
		if sequence.size() > inputs.size():
			continue
		var offset := inputs.size() - sequence.size()
		var matches := true
		for index in range(sequence.size()):
			if str(inputs[offset + index].action) != str(sequence[index]):
				matches = false
				break
		if matches:
			inputs.clear()
			return str(combo.attack)
	return ""

func _prune(now: float) -> void:
	while not inputs.is_empty() and now - float(inputs.front().time) > INPUT_WINDOW:
		inputs.pop_front()
