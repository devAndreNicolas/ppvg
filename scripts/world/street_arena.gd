class_name StreetArena
extends Node2D

var backdrop: Node2D
var crowd: Node2D

func _ready() -> void:
	backdrop = $Backdrop
	crowd = $Crowd

func present(next_energy: float, next_pulse: float, next_color: Color) -> void:
	if backdrop == null:
		backdrop = get_node_or_null("Backdrop")
		crowd = get_node_or_null("Crowd")
	if backdrop == null or crowd == null:
		return
	backdrop.set_act_color(next_color)
	crowd.present(next_energy, next_pulse, next_color)
