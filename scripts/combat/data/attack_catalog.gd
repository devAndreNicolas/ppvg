class_name AttackCatalog
extends RefCounted

const ATTACKS := {
	"light": {"id": "light", "label": "LEVE", "power": 1, "reach": 125.0, "duration": 0.30, "impact": 0.12, "area": 95.0, "color": Color("35e6ff")},
	"heavy": {"id": "heavy", "label": "FORTE", "power": 2, "reach": 180.0, "duration": 0.50, "impact": 0.23, "area": 105.0, "color": Color("ff3bac")},
	"sweep": {"id": "sweep", "label": "VARRIDA", "power": 2, "reach": 165.0, "duration": 0.46, "impact": 0.25, "area": 165.0, "color": Color("ffad4d"), "wide": true},
	"launcher": {"id": "launcher", "label": "LANÇADOR", "power": 3, "reach": 170.0, "duration": 0.58, "impact": 0.30, "area": 100.0, "color": Color("8d7dff")},
	"stomp": {"id": "stomp", "label": "PASSO PESADO", "power": 2, "reach": 230.0, "duration": 0.52, "impact": 0.28, "area": 220.0, "color": Color("ff3bac"), "wide": true},
	"dash": {"id": "dash", "label": "CORTE DE RUA", "power": 2, "reach": 235.0, "duration": 0.38, "impact": 0.15, "area": 105.0, "color": Color("35e6ff"), "dash": true}
}

const COMBOS := [
	{"sequence": ["J", "J", "J"], "attack": "sweep", "hint": "J J J  VARRIDA"},
	{"sequence": ["J", "J", "K"], "attack": "launcher", "hint": "J J K  LANÇADOR"},
	{"sequence": ["J", "K"], "attack": "stomp", "hint": "J K  PASSO PESADO"},
	{"sequence": ["D", "J"], "attack": "dash", "hint": "L + J  CORTE DE RUA"}
]

static func attack(id: String) -> Dictionary:
	return ATTACKS.get(id, ATTACKS.light).duplicate(true)

static func combo_hints() -> Array:
	return COMBOS.duplicate(true)
