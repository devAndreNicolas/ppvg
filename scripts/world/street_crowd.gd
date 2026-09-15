class_name StreetCrowd
extends Node2D

var crowd_energy := 55.0
var pulse := 0.0
var act_color := Color("35e6ff")
var redraw_clock := 0.0

func present(next_energy: float, next_pulse: float, next_color: Color) -> void:
	crowd_energy = next_energy
	pulse = next_pulse
	act_color = next_color

func _process(delta: float) -> void:
	redraw_clock += delta
	if redraw_clock >= 0.05:
		redraw_clock = 0.0
		queue_redraw()

func _draw() -> void:
	for x in range(150, 1880, 145):
		var rise := sin(float(x) * 0.19 + Time.get_ticks_msec() * 0.006) * (4.0 + pulse * 15.0)
		var crowd_color := act_color.lerp(Color("ff3bac"), fmod(float(x), 3.0) / 3.0)
		draw_circle(Vector2(x, 635 + rise), 11, Color(crowd_color, 0.68 + crowd_energy * 0.002))
		draw_line(Vector2(x, 646 + rise), Vector2(x + sin(float(x)) * 8.0, 669 + rise), crowd_color, 4.0)
