class_name ShowHud
extends Node2D

var state := "title"
var score := 0
var combo := 0
var crowd := 55.0
var notes := 0
var grave_time := 0.0
var duplo_time := 0.0
var act_name := "CHEGADA"
var lyric := ""
var timing_label := ""
var final_rank := ""
var diagnostics_visible := false
var diagnostics_clock := 0.0
var view_key := ""
var combat_visible := true

@onready var beat_rail: BeatRail = $BeatRail
@onready var ability_bar: Node2D = $AbilityBar

func present(next_state: String, next_score: int, next_combo: int, next_crowd: float, next_notes: int, next_grave: float, next_duplo: float, next_act: String, next_pulse: float, next_phase: float, next_lyric: String, next_label: String, next_rank: String, next_slots: Array[Dictionary], next_combat_visible: bool) -> void:
	state = next_state
	score = next_score
	combo = next_combo
	crowd = next_crowd
	notes = next_notes
	grave_time = next_grave
	duplo_time = next_duplo
	act_name = next_act
	lyric = next_lyric
	timing_label = next_label
	final_rank = next_rank
	combat_visible = next_combat_visible
	beat_rail.present(next_phase, next_pulse, state == "playing" and combat_visible)
	ability_bar.visible = state == "playing" and combat_visible
	ability_bar.call("present", next_slots)
	var next_key := "%s|%s|%d|%d|%d|%d|%d|%s|%s|%s|%s" % [state, act_name, score, combo, int(crowd), notes, int(grave_time * 10.0) + int(duplo_time * 10.0), lyric, timing_label, final_rank, combat_visible]
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
	var font := ThemeDB.fallback_font
	if state == "title":
		_draw_title(font)
	elif state == "ending":
		_draw_ending(font)
	elif combat_visible:
		_draw_playing(font)
	if diagnostics_visible:
		_draw_diagnostics(font)

func _draw_title(font: Font) -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color(0.01, 0.01, 0.05, 0.74), true)
	draw_string(font, Vector2(0, 164), "A RODA", HORIZONTAL_ALIGNMENT_CENTER, 1920, 78, Color.WHITE)
	draw_string(font, Vector2(0, 212), "EDRIEL - PERDER PRA VOCE GANHAR", HORIZONTAL_ALIGNMENT_CENTER, 1920, 22, Color("35e6ff"))
	draw_string(font, Vector2(0, 290), "WASD/SETAS MOVE  |  J LEVE  |  K FORTE  |  L/SHIFT ESQUIVA", HORIZONTAL_ALIGNMENT_CENTER, 1920, 19, Color("d7d4ff"))
	_draw_combo_strip(font, Rect2(330, 372, 1260, 118), true)
	draw_string(font, Vector2(0, 575), "U PAUSA (4 NOTAS)  |  I GRAVE x3 (6 NOTAS)  |  O DUPLO (COMBO 15 + PUBLICO 100%)", HORIZONTAL_ALIGNMENT_CENTER, 1920, 18, Color("ffad4d"))
	draw_string(font, Vector2(0, 690), "[ ESPACO PARA ENTRAR NA RODA ]", HORIZONTAL_ALIGNMENT_CENTER, 1920, 27, Color("ff3bac"))

func _draw_ending(font: Font) -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color(0.01, 0.01, 0.05, 0.50), true)
	draw_string(font, Vector2(0, 425), "A ULTIMA NOTA E SUA", HORIZONTAL_ALIGNMENT_CENTER, 1920, 56, Color.WHITE)
	draw_string(font, Vector2(0, 500), final_rank, HORIZONTAL_ALIGNMENT_CENTER, 1920, 32, Color("35e6ff"))
	draw_string(font, Vector2(0, 548), "PONTOS %d" % score, HORIZONTAL_ALIGNMENT_CENTER, 1920, 22, Color("ff3bac"))
	draw_string(font, Vector2(0, 655), "[ R PARA RECOMECAR ]", HORIZONTAL_ALIGNMENT_CENTER, 1920, 20, Color.WHITE)

func _draw_playing(font: Font) -> void:
	draw_string(font, Vector2(42, 58), act_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("d7d4ff"))
	if combo > 0:
		draw_string(font, Vector2(42, 88), "COMBO x%d" % combo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("35e6ff"))
	if timing_label != "":
		draw_string(font, Vector2(0, 150), timing_label, HORIZONTAL_ALIGNMENT_CENTER, 1920, 27, Color("ffad4d") if timing_label == "PERFECT" else Color("35e6ff"))
	_draw_combo_strip(font, Rect2(165, 910, 935, 94), false)
	if lyric != "":
		draw_string(font, Vector2(0, 865), lyric, HORIZONTAL_ALIGNMENT_CENTER, 1920, 22, Color.WHITE)

func _draw_combo_strip(font: Font, rect: Rect2, large: bool) -> void:
	draw_rect(rect, Color("080812", 0.78), true)
	draw_line(Vector2(rect.position.x, rect.position.y), Vector2(rect.end.x, rect.position.y), Color("35e6ff", 0.72), 2.0)
	var text_size := 22 if large else 15
	draw_string(font, rect.position + Vector2(24, 33), "COMBOS" if large else "SEQUENCIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffad4d"))
	var combos := "J J J VARRIDA  |  J J K LANCADOR  |  J K PASSO PESADO  |  L + J CORTE"
	draw_string(font, rect.position + Vector2(142, 39), combos, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 155.0, text_size, Color.WHITE)
	if large:
		draw_string(font, rect.position + Vector2(142, 78), "APERTE NO RITMO: a nota cruza a linha dourada", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d7d4ff"))

func _draw_diagnostics(font: Font) -> void:
	var fps := Engine.get_frames_per_second()
	draw_rect(Rect2(1615, 28, 265, 54), Color("080812", 0.82), true)
	draw_string(font, Vector2(1632, 60), "FPS %d | 720p PERFORMANCE" % fps, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("35e6ff") if fps >= 58 else Color("ffad4d"))
