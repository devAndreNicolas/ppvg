class_name AbilitySystem
extends RefCounted

const STUN_COST := 4
const GRAVE_COST := 6
const ULTIMATE_COMBO := 15
const GRAVE_DURATION := 4.0
const DUPLO_DURATION := 5.0
const STUN_COOLDOWN := 5.0
const GRAVE_COOLDOWN := 8.0
const DUPLO_COOLDOWN := 15.0

var notes := 0
var grave_time := 0.0
var duplo_time := 0.0
var stun_cooldown := 0.0
var grave_cooldown := 0.0
var duplo_cooldown := 0.0

func tick(delta: float) -> void:
	grave_time = maxf(grave_time - delta, 0.0)
	duplo_time = maxf(duplo_time - delta, 0.0)
	stun_cooldown = maxf(stun_cooldown - delta, 0.0)
	grave_cooldown = maxf(grave_cooldown - delta, 0.0)
	duplo_cooldown = maxf(duplo_cooldown - delta, 0.0)

func add_notes(amount: int) -> void:
	notes = min(notes + amount, 12)

func cast(id: String, combo: int, crowd: float) -> bool:
	match id:
		"stun":
			if notes < STUN_COST or stun_cooldown > 0.0:
				return false
			notes -= STUN_COST
			stun_cooldown = STUN_COOLDOWN
			return true
		"grave":
			if notes < GRAVE_COST or grave_cooldown > 0.0:
				return false
			notes -= GRAVE_COST
			grave_time = GRAVE_DURATION
			grave_cooldown = GRAVE_COOLDOWN
			return true
		"duplo":
			if duplo_cooldown > 0.0 or combo < ULTIMATE_COMBO or crowd < 100.0:
				return false
			duplo_time = DUPLO_DURATION
			duplo_cooldown = DUPLO_COOLDOWN
			return true
	return false

func slot_states(combo: int, crowd: float) -> Array[Dictionary]:
	return [
		_slot_state("stun", "U", "PAUSA", Color("35e6ff"), stun_cooldown, 0.0, _stun_requirement()),
		_slot_state("grave", "I", "GRAVE", Color("ff3bac"), grave_cooldown, grave_time, _grave_requirement()),
		_slot_state("duplo", "O", "DUPLO", Color("8d7dff"), duplo_cooldown, duplo_time, _duplo_requirement(combo, crowd))
	]

func _slot_state(id: String, key: String, title: String, color: Color, cooldown: float, active_time: float, requirement: String) -> Dictionary:
	var status := "ready"
	if active_time > 0.0:
		status = "active"
	elif cooldown > 0.0:
		status = "cooldown"
	elif not requirement.is_empty():
		status = "locked"
	return {
		"id": id,
		"key": key,
		"title": title,
		"color": color,
		"status": status,
		"cooldown": cooldown,
		"active_time": active_time,
		"requirement": requirement
	}

func _stun_requirement() -> String:
	return "%d NOTAS" % STUN_COST if notes < STUN_COST else ""

func _grave_requirement() -> String:
	return "%d NOTAS" % GRAVE_COST if notes < GRAVE_COST else ""

func _duplo_requirement(combo: int, crowd: float) -> String:
	if combo < ULTIMATE_COMBO:
		return "COMBO %d" % ULTIMATE_COMBO
	if crowd < 100.0:
		return "PUBLICO 100%%"
	return ""

func damage_multiplier() -> int:
	return 3 if grave_time > 0.0 else 1

func public_guarded() -> bool:
	return duplo_time > 0.0
