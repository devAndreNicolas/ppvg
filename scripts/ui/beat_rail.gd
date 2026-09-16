class_name BeatRail
extends Node2D

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

var phase := 0.0
var pulse := 0.0

func present(next_phase: float, next_pulse: float, next_active: bool) -> void:
	phase = next_phase
	pulse = next_pulse
	visible = next_active
	if next_active:
		queue_redraw()

func _draw() -> void:
	var target := Vector2(960, 835)
	draw_line(Vector2(515, target.y), Vector2(1405, target.y), Color(UiTheme.MUTED, 0.85), 2.0)
	draw_line(Vector2(target.x, 810), Vector2(target.x, 860), UiTheme.AMBER, 4.0)
	for step in range(-4, 5):
		var note_x := target.x + (float(step) - phase) * 112.0
		if note_x < 510.0 or note_x > 1410.0:
			continue
		var size := 11.0 + pulse * 7.0 if step == 0 else 8.0
		draw_circle(Vector2(note_x, target.y), size, UiTheme.CYAN if step >= 0 else UiTheme.MUTED)
