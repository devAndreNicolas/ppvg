class_name StreetBackdrop
extends Node2D

var act_color := Color("35e6ff")

func set_act_color(next_color: Color) -> void:
	if act_color.is_equal_approx(next_color):
		return
	act_color = next_color
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color("080812"), true)
	draw_rect(Rect2(0, 0, 1920, 420), Color("111027"), true)
	for x in range(90, 1920, 135):
		var building_height := 120 + int(absf(sin(float(x) * 0.07)) * 180.0)
		draw_rect(Rect2(x, 420 - building_height, 78, building_height), Color("17143a"), true)
		draw_line(Vector2(x + 12, 400 - building_height), Vector2(x + 62, 400 - building_height), act_color, 2.0)
	draw_rect(Rect2(0, 690, 1920, 390), Color("15152a"), true)
	for y in range(710, 1080, 72):
		draw_line(Vector2(0, y), Vector2(1920, y), Color("27244a"), 2.0)
