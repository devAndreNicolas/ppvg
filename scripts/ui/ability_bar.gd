class_name AbilityBar
extends Node2D

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

var slots: Array[Dictionary] = []
var view_key := ""

func present(next_slots: Array[Dictionary]) -> void:
	slots = next_slots
	var next_key := ""
	for slot in slots:
		next_key += "%s|%s|%d|%s;" % [str(slot.id), str(slot.status), int(ceilf(float(slot.cooldown))), str(slot.requirement)]
		if str(slot.status) == "active":
			next_key += "%d;" % int(ceilf(float(slot.active_time)))
	if view_key != next_key:
		view_key = next_key
		queue_redraw()

func _draw() -> void:
	var font := UiTheme.body_font()
	for index in range(slots.size()):
		_draw_slot(font, slots[index], Vector2(1125.0 + index * 155.0, 910.0))

func _draw_slot(font: Font, slot: Dictionary, origin: Vector2) -> void:
	var color: Color = slot.color
	var status := str(slot.status)
	var rect := Rect2(origin, Vector2(145, 94))
	var border := color if status == "ready" or status == "active" else UiTheme.MUTED
	draw_rect(rect, Color(UiTheme.INK, 0.88), true)
	draw_rect(rect, border, false, 2.0)
	draw_string(font, origin + Vector2(14, 38), str(slot.key), HORIZONTAL_ALIGNMENT_LEFT, -1, 31, border)
	draw_string(font, origin + Vector2(59, 30), str(slot.title), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UiTheme.CREAM)
	if status == "ready":
		draw_string(font, origin + Vector2(59, 62), "PRONTA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)
		draw_circle(origin + Vector2(126, 18), 5.0, color)
	elif status == "active":
		var active_left: float = float(slot.active_time)
		draw_rect(Rect2(origin + Vector2(4, 4), Vector2(137, 86)), Color(color, 0.16), true)
		draw_string(font, origin + Vector2(59, 62), "ATIVA %.1fs" % active_left, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)
		draw_arc(origin + Vector2(126, 18), 9.0, 0.0, TAU, 16, color, 2.0)
	elif status == "cooldown":
		var cooldown_left: float = float(slot.cooldown)
		draw_rect(Rect2(origin + Vector2(2, 2), Vector2(141, 90)), Color(UiTheme.INK, 0.78), true)
		draw_string(font, origin + Vector2(0, 66), "%.1f" % cooldown_left, HORIZONTAL_ALIGNMENT_CENTER, 145, 27, UiTheme.CREAM)
	else:
		draw_rect(Rect2(origin + Vector2(2, 2), Vector2(141, 90)), Color(UiTheme.INK, 0.62), true)
		draw_string(font, origin + Vector2(59, 62), str(slot.requirement), HORIZONTAL_ALIGNMENT_LEFT, 78, 13, UiTheme.MUTED)
