class_name StreetRival
extends Node2D

signal strike_attempt(rival: StreetRival)
signal defeated(rival: StreetRival)

var kind := 0
var health := 3
var speed := 155.0
var attack_range := 78.0
var attack_cooldown := 0.9
var cooldown := 0.5
var attack_timer := 0.0
var hit_timer := 0.0
var knockback := Vector2.ZERO
var hit_fired := false
var tint := Color("ff3bac")
var stun_timer := 0.0

func setup(next_kind: int) -> void:
	kind = next_kind
	match kind:
		0:
			health = 3
			speed = 180.0
			tint = Color("ff3bac")
		1:
			health = 2
			speed = 245.0
			tint = Color("ffad4d")
		_:
			health = 4
			speed = 125.0
			tint = Color("8d7dff")

func tick(delta: float, target: Vector2) -> void:
	hit_timer = maxf(hit_timer - delta, 0.0)
	stun_timer = maxf(stun_timer - delta, 0.0)
	cooldown = maxf(cooldown - delta, 0.0)
	if stun_timer > 0.0:
		queue_redraw()
		return
	if knockback.length() > 1.0:
		position += knockback * delta
		knockback = knockback.move_toward(Vector2.ZERO, 1600.0 * delta)
		queue_redraw()
		return
	var difference := target - position
	if attack_timer > 0.0:
		attack_timer -= delta
		if not hit_fired and attack_timer <= 0.18:
			hit_fired = true
			emit_signal("strike_attempt", self)
		queue_redraw()
		return
	if difference.length() > attack_range:
		var drift := Vector2(0.0, sin(Time.get_ticks_msec() * 0.004 + kind) * 0.25)
		position += (difference.normalized() + drift).normalized() * speed * delta
	elif cooldown <= 0.0:
		attack_timer = 0.38
		cooldown = attack_cooldown + float(kind) * 0.12
		hit_fired = false
	queue_redraw()

func receive_hit(direction: Vector2, power: int, timing: float) -> void:
	health -= power
	hit_timer = 0.22
	knockback = direction.normalized() * (450.0 + power * 180.0) * (1.0 + timing * 0.35)
	if health <= 0:
		emit_signal("defeated", self)

func apply_stun(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration)

func _draw() -> void:
	var color := Color.WHITE if hit_timer > 0.0 else tint
	draw_circle(Vector2(0, -46), 21, color)
	draw_rect(Rect2(-23, -24, 46, 61), Color("171132"), true)
	draw_line(Vector2(-15, 35), Vector2(-23, 68), tint, 9.0)
	draw_line(Vector2(15, 35), Vector2(23, 68), tint, 9.0)
	draw_arc(Vector2.ZERO, 42, 0.0, TAU, 20, tint, 1.5)
	if attack_timer > 0.0:
		draw_circle(Vector2(0, -8), 46, Color(tint, 0.14))
	if stun_timer > 0.0:
		draw_arc(Vector2(0, -25), 37, 0.0, TAU, 16, Color("35e6ff"), 3.0)
