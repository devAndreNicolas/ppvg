class_name UiTheme
extends RefCounted

static var _display_font: FontFile
static var _body_font: FontFile

const INK := Color("0b080b")
const WINE := Color("6e1732")
const WINE_DEEP := Color("260d17")
const CREAM := Color("f2e6d0")
const CHROME := Color("c8c2bc")
const AMBER := Color("e5a84b")
const CYAN := Color("5cd9df")
const MUTED := Color("8e8490")

static func display_font() -> Font:
	if _display_font == null:
		_display_font = FontFile.new()
		_display_font.load_dynamic_font("res://assets/ui/fonts/BodoniModa.ttf")
	return _display_font

static func body_font() -> Font:
	if _body_font == null:
		_body_font = FontFile.new()
		_body_font.load_dynamic_font("res://assets/ui/fonts/Barlow-Regular.ttf")
	return _body_font

static func draw_chrome_panel(canvas: CanvasItem, rect: Rect2, alpha: float = 0.90) -> void:
	canvas.draw_rect(rect, Color(INK, alpha), true)
	canvas.draw_line(rect.position, Vector2(rect.end.x, rect.position.y), CHROME, 1.0)
	canvas.draw_line(Vector2(rect.position.x, rect.end.y), rect.end, Color(WINE, 0.92), 2.0)

static func draw_keycap(canvas: CanvasItem, key: String, rect: Rect2, selected: bool = false) -> void:
	var border := AMBER if selected else Color(CHROME, 0.68)
	canvas.draw_rect(rect, Color(WINE_DEEP, 0.92), true)
	canvas.draw_rect(rect, border, false, 1.0)
	canvas.draw_string(body_font(), rect.position + Vector2(0, rect.size.y * 0.68), key, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 15, border)
