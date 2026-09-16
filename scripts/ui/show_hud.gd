class_name ShowHud
extends Node2D

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

var state := "hidden"
var combo := 0
var act_name := ""
var lyric := ""
var timing_label := ""
var diagnostics_visible := false
var diagnostics_clock := 0.0
var combat_visible := false
var view_key := ""

@onready var beat_rail: BeatRail = $BeatRail
@onready var ability_bar: Node2D = $AbilityBar

func present(next_state: String, _score: int, next_combo: int, _crowd: float, _notes: int, _grave: float, _duplo: float, next_act: String, next_pulse: float, next_phase: float, next_lyric: String, next_label: String, _rank: String, next_slots: Array[Dictionary], next_combat_visible: bool) -> void:
	state = next_state
	combo = next_combo
	act_name = next_act
	lyric = next_lyric
	timing_label = next_label
	combat_visible = next_combat_visible
	beat_rail.present(next_phase, next_pulse, state == "playing" and combat_visible)
	ability_bar.visible = state == "playing" and combat_visible
	ability_bar.call("present", next_slots)
	var next_key := "%s|%d|%s|%s|%s|%s" % [state, combo, act_name, lyric, timing_label, combat_visible]
	if view_key != next_key:
		view_key = next_key
		queue_redraw()

func toggle_diagnostics() -> void:
	diagnostics_visible = not diagnostics_visible
	queue_redraw()

func _process(delta: float) -> void:
	if diagnostics_visible:
		diagnostics_clock += delta
		if diagnostics_clock >= 0.25:
			diagnostics_clock = 0.0
			queue_redraw()

func _draw() -> void:
	if state == "playing" and combat_visible:
		_draw_playing(UiTheme.body_font())
	if diagnostics_visible:
		_draw_diagnostics(UiTheme.body_font())

func _draw_playing(font: Font) -> void:
	draw_string(font, Vector2(42, 58), act_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, UiTheme.CREAM)
	if combo > 0:
		draw_string(font, Vector2(42, 88), "COMBO x%d" % combo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, UiTheme.CYAN)
	if timing_label != "":
		draw_string(font, Vector2(0, 150), timing_label, HORIZONTAL_ALIGNMENT_CENTER, 1920, 27, UiTheme.AMBER if timing_label == "PERFECT" else UiTheme.CYAN)
	_draw_combo_strip(font, Rect2(165, 910, 935, 94))
	if lyric != "":
		draw_string(font, Vector2(0, 865), lyric, HORIZONTAL_ALIGNMENT_CENTER, 1920, 22, UiTheme.CREAM)

func _draw_combo_strip(font: Font, rect: Rect2) -> void:
	draw_rect(rect, Color(UiTheme.INK, 0.78), true)
	draw_line(rect.position, Vector2(rect.end.x, rect.position.y), Color(UiTheme.CYAN, 0.72), 2.0)
	draw_string(font, rect.position + Vector2(24, 33), "SEQUENCIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, UiTheme.AMBER)
	draw_string(font, rect.position + Vector2(142, 39), "J J J VARRIDA  |  J J K LANCADOR  |  J K PASSO PESADO  |  L + J CORTE", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 155.0, 15, UiTheme.CREAM)

func _draw_diagnostics(font: Font) -> void:
	var fps := Engine.get_frames_per_second()
	draw_rect(Rect2(1615, 28, 265, 54), Color(UiTheme.INK, 0.82), true)
	draw_string(font, Vector2(1632, 60), "FPS %d | 720p PERFORMANCE" % fps, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, UiTheme.CYAN if fps >= 58 else UiTheme.AMBER)
