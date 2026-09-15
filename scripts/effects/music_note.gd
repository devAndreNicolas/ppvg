class_name MusicNote
extends Node2D

signal collected(note: MusicNote, amount: int)
signal expired(note: MusicNote)

var amount := 1
var life := 0.0
var drift := Vector2.ZERO
var phase := 0.0
var active := false

func setup(next_amount: int, direction: Vector2) -> void:
	amount = next_amount
	life = 6.0
	drift = direction.normalized() * 260.0
	phase = randf() * TAU
	active = true
	visible = true
	queue_redraw()

func deactivate() -> void:
	active = false
	visible = false

func tick(delta: float, player_position: Vector2) -> void:
	if not active:
		return
	life -= delta
	phase += delta * 5.0
	position += drift * delta
	drift = drift.move_toward(Vector2.ZERO, 400.0 * delta)
	if position.distance_to(player_position) < 48.0:
		active = false
		visible = false
		emit_signal("collected", self, amount)
	elif life <= 0.0:
		active = false
		visible = false
		emit_signal("expired", self)
	else:
		queue_redraw()

func _draw() -> void:
	var glow := 11.0 + sin(phase) * 3.0
	draw_circle(Vector2.ZERO, glow, Color("35e6ff", 0.14))
	draw_circle(Vector2.ZERO, 7.0, Color("ffad4d"))
	draw_circle(Vector2(5, -8), 4.0, Color("ff3bac"))
	draw_line(Vector2(6, -7), Vector2(6, -28), Color.WHITE, 3.0)
	draw_line(Vector2(6, -28), Vector2(18, -24), Color.WHITE, 3.0)
