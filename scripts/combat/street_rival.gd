class_name StreetRival
extends Node2D

const ARENA := Rect2(240, 700, 1440, 230)

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
var visual: AnimatedSprite2D
var visual_state: StringName = &""

func _ready() -> void:
	visual = get_node_or_null("Visual") as AnimatedSprite2D
	_apply_visual()

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
	if is_node_ready():
		_apply_visual()

func _apply_visual() -> void:
	if visual == null:
		return
	visual.sprite_frames = SpriteLibrary.rival(kind)
	visual.scale = Vector2.ONE * (0.42 if kind % 2 == 1 else 0.38)
	visual_state = &""
	_set_visual(&"idle")

func tick(delta: float, target: Vector2) -> void:
	hit_timer = maxf(hit_timer - delta, 0.0)
	stun_timer = maxf(stun_timer - delta, 0.0)
	cooldown = maxf(cooldown - delta, 0.0)
	if stun_timer > 0.0:
		_set_visual(&"idle")
		queue_redraw()
		return
	if knockback.length() > 1.0:
		position += knockback * delta
		_clamp_to_arena()
		knockback = knockback.move_toward(Vector2.ZERO, 1600.0 * delta)
		_set_visual(&"walk")
		queue_redraw()
		return
	var difference := target - position
	if attack_timer > 0.0:
		attack_timer -= delta
		if not hit_fired and attack_timer <= 0.18:
			hit_fired = true
			emit_signal("strike_attempt", self)
			queue_redraw()
		_set_visual(&"attack")
		return
	if difference.length() > attack_range:
		var drift := Vector2(0.0, sin(Time.get_ticks_msec() * 0.004 + kind) * 0.25)
		position += (difference.normalized() + drift).normalized() * speed * delta
		_clamp_to_arena()
		if visual != null:
			visual.flip_h = difference.x < 0.0
		_set_visual(&"walk")
	elif cooldown <= 0.0:
		attack_timer = 0.38
		cooldown = attack_cooldown + float(kind) * 0.12
		hit_fired = false
		_set_visual(&"attack")
	else:
		_set_visual(&"idle")
	queue_redraw()

func _clamp_to_arena() -> void:
	position.x = clampf(position.x, ARENA.position.x, ARENA.end.x)
	position.y = clampf(position.y, ARENA.position.y, ARENA.end.y)

func _set_visual(next_state: StringName) -> void:
	if visual == null or visual_state == next_state:
		return
	visual_state = next_state
	visual.play(next_state)

func receive_hit(direction: Vector2, power: int, timing: float) -> void:
	health -= power
	hit_timer = 0.22
	knockback = direction.normalized() * (450.0 + power * 180.0) * (1.0 + timing * 0.35)
	if health <= 0:
		emit_signal("defeated", self)

func apply_stun(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration)

func _draw() -> void:
	if attack_timer > 0.0:
		draw_circle(Vector2(0, -8), 46, Color(tint, 0.14))
	if stun_timer > 0.0:
		draw_arc(Vector2(0, -25), 37, 0.0, TAU, 16, Color("35e6ff"), 3.0)
