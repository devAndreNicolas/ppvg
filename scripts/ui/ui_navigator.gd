class_name UiNavigator
extends Node2D

const UiTheme = preload("res://scripts/ui/ui_theme.gd")

signal start_requested
signal restart_requested
signal main_menu_requested
signal resume_requested
signal quit_requested

var screen := "main"
var return_screen := "main"
var selected := 0
var score := 0
var rank := ""
var pulse_time := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	queue_redraw()

func show_main() -> void:
	screen = "main"
	selected = 0
	visible = true
	queue_redraw()

func show_pause() -> void:
	screen = "pause"
	selected = 0
	visible = true
	queue_redraw()

func show_results(next_score: int, next_rank: String) -> void:
	screen = "results"
	score = next_score
	rank = next_rank
	selected = 0
	visible = true
	queue_redraw()

func hide_all() -> void:
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	pulse_time += delta
	if fmod(pulse_time, 0.12) < delta:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_ESCAPE:
		_back()
		return
	if event.keycode == KEY_UP or event.keycode == KEY_W:
		selected = posmod(selected - 1, _items().size())
		queue_redraw()
		return
	if event.keycode == KEY_DOWN or event.keycode == KEY_S:
		selected = posmod(selected + 1, _items().size())
		queue_redraw()
		return
	if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
		_activate(_items()[selected])

func _items() -> PackedStringArray:
	match screen:
		"main":
			return ["INICIAR", "CONTROLES", "CREDITOS", "SAIR"]
		"pause":
			return ["CONTINUAR", "RECOMECAR", "CONTROLES", "MENU PRINCIPAL"]
		"results":
			return ["JOGAR DE NOVO", "MENU PRINCIPAL"]
		_:
			return ["VOLTAR"]

func _activate(item: String) -> void:
	match item:
		"INICIAR":
			emit_signal("start_requested")
		"CONTINUAR":
			emit_signal("resume_requested")
		"RECOMECAR", "JOGAR DE NOVO":
			emit_signal("restart_requested")
		"MENU PRINCIPAL":
			emit_signal("main_menu_requested")
		"CONTROLES":
			return_screen = screen
			screen = "controls"
			selected = 0
			queue_redraw()
		"CREDITOS":
			return_screen = screen
			screen = "credits"
			selected = 0
			queue_redraw()
		"SAIR":
			emit_signal("quit_requested")
		"VOLTAR":
			_back()

func _back() -> void:
	if screen == "pause":
		emit_signal("resume_requested")
	elif screen == "controls" or screen == "credits":
		screen = return_screen
		selected = 0
		queue_redraw()
	elif screen == "results":
		emit_signal("main_menu_requested")

func _draw() -> void:
	_draw_backdrop()
	match screen:
		"main": _draw_main()
		"pause": _draw_pause()
		"controls": _draw_controls()
		"credits": _draw_credits()
		"results": _draw_results()

func _draw_backdrop() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color(UiTheme.INK, 0.79), true)
	var breath := (sin(pulse_time * 2.0) + 1.0) * 0.5
	for index in range(7):
		var point := Vector2(180.0 + index * 280.0, 140.0 + fmod(float(index * 173), 700.0))
		draw_circle(point, 60.0 + breath * 12.0, Color(UiTheme.WINE if index % 2 == 0 else UiTheme.AMBER, 0.055))
	draw_line(Vector2(84, 84), Vector2(1836, 84), Color(UiTheme.CHROME, 0.55), 1.0)
	draw_string(UiTheme.body_font(), Vector2(92, 58), "EDRIEL", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, UiTheme.CREAM)
	draw_string(UiTheme.body_font(), Vector2(0, 58), "PERDER PRA VOCE GANHAR", HORIZONTAL_ALIGNMENT_RIGHT, 1828, 17, UiTheme.AMBER)

func _draw_main() -> void:
	_draw_menu_list(Rect2(660, 330, 600, 410))
	draw_string(UiTheme.body_font(), Vector2(0, 820), "WASD / SETAS PARA NAVEGAR  ·  ENTER / ESPACO PARA CONFIRMAR", HORIZONTAL_ALIGNMENT_CENTER, 1920, 15, UiTheme.MUTED)

func _draw_pause() -> void:
	_draw_center_title("PAUSA", "A MUSICA E A RODA ESTAO PARADAS")
	_draw_menu_list(Rect2(660, 385, 600, 350))

func _draw_controls() -> void:
	_draw_center_title("CONTROLES", "MOVIMENTO, RITMO E HABILIDADES")
	var panel := Rect2(480, 328, 960, 480)
	UiTheme.draw_chrome_panel(self, panel)
	var controls := [["WASD / SETAS", "MOVER"], ["J / K", "GOLPES E COMBOS"], ["L / SHIFT", "ESQUIVA"], ["U / I / O", "HABILIDADES"], ["ESC", "PAUSAR"]]
	for index in range(controls.size()):
		var y := panel.position.y + 72.0 + index * 72.0
		UiTheme.draw_keycap(self, str(controls[index][0]), Rect2(panel.position.x + 48, y - 31, 220, 42))
		draw_string(UiTheme.body_font(), Vector2(panel.position.x + 308, y), str(controls[index][1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, UiTheme.CREAM)
	draw_string(UiTheme.body_font(), Vector2(0, 858), "ESC PARA VOLTAR", HORIZONTAL_ALIGNMENT_CENTER, 1920, 16, UiTheme.AMBER)

func _draw_credits() -> void:
	_draw_center_title("CREDITOS", "O QUE ESTA CONFIRMADO")
	var panel := Rect2(600, 350, 720, 360)
	UiTheme.draw_chrome_panel(self, panel)
	draw_string(UiTheme.display_font(), Vector2(0, 455), "EDRIEL", HORIZONTAL_ALIGNMENT_CENTER, 1920, 58, UiTheme.CREAM)
	draw_string(UiTheme.body_font(), Vector2(0, 510), "PERDER PRA VOCE GANHAR", HORIZONTAL_ALIGNMENT_CENTER, 1920, 23, UiTheme.AMBER)
	draw_string(UiTheme.body_font(), Vector2(0, 565), "FEITO COM GODOT 4", HORIZONTAL_ALIGNMENT_CENTER, 1920, 17, UiTheme.CHROME)
	draw_string(UiTheme.body_font(), Vector2(0, 770), "ESC PARA VOLTAR", HORIZONTAL_ALIGNMENT_CENTER, 1920, 16, UiTheme.AMBER)

func _draw_results() -> void:
	_draw_center_title("A ULTIMA NOTA E SUA", rank)
	draw_string(UiTheme.body_font(), Vector2(0, 358), "PONTOS %d" % score, HORIZONTAL_ALIGNMENT_CENTER, 1920, 21, UiTheme.AMBER)
	_draw_menu_list(Rect2(660, 470, 600, 210))

func _draw_center_title(title: String, subtitle: String) -> void:
	draw_string(UiTheme.display_font(), Vector2(0, 250), title, HORIZONTAL_ALIGNMENT_CENTER, 1920, 72, UiTheme.CREAM)
	draw_string(UiTheme.body_font(), Vector2(0, 295), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 1920, 18, UiTheme.AMBER)

func _draw_menu_list(rect: Rect2) -> void:
	UiTheme.draw_chrome_panel(self, rect)
	var items := _items()
	for index in range(items.size()):
		var item_rect := Rect2(rect.position + Vector2(34, 42 + index * 76), Vector2(rect.size.x - 68, 54))
		var is_selected := index == selected
		if is_selected:
			draw_rect(item_rect, Color(UiTheme.WINE, 0.86), true)
			draw_rect(item_rect, UiTheme.AMBER, false, 1.0)
			draw_circle(item_rect.position + Vector2(18, 27), 4.0 + sin(pulse_time * 5.0) * 1.5, UiTheme.AMBER)
		draw_string(UiTheme.body_font(), item_rect.position + Vector2(42, 36), items[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 23, UiTheme.CREAM if is_selected else UiTheme.CHROME)
