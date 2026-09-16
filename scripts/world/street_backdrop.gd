class_name StreetBackdrop
extends Node2D

const FAR := preload("res://assets/background/bg_far.jpg")
const MID := preload("res://assets/background/bg_mid.png")
const NEAR := preload("res://assets/background/bg_near.png")

var act_color := Color("35e6ff")
var elapsed := 0.0
var redraw_clock := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	redraw_clock += delta
	if redraw_clock >= 0.05:
		redraw_clock = 0.0
		queue_redraw()

func set_act_color(next_color: Color) -> void:
	act_color = next_color

func _draw() -> void:
	var far_shift := sin(elapsed * 0.16) * 8.0
	var mid_shift := sin(elapsed * 0.22 + 0.8) * 13.0
	draw_texture_rect(FAR, Rect2(-18.0 + far_shift, -10.0, 1956.0, 1100.0), false)
	draw_texture_rect(MID, Rect2(-24.0 + mid_shift, -8.0, 1968.0, 1096.0), false)
	draw_texture_rect(NEAR, Rect2(0.0, 0.0, 1920.0, 1080.0), false)
	draw_rect(Rect2(0.0, 0.0, 1920.0, 1080.0), Color(act_color, 0.035), true)
