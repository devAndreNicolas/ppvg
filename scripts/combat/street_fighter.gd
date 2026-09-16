class_name StreetFighter
extends Node2D

signal attack_impact(attack: Dictionary, timing: float, damage_multiplier: int, duplicated: bool)
signal ability_cast(id: String)
signal timing_judged(label: String, quality: float)

const WALK_SPEED := 440.0
const DODGE_SPEED := 1100.0
const ARENA := Rect2(240, 700, 1440, 230)

var reader := ComboReader.new()
var abilities := AbilitySystem.new()
var facing := 1.0
var velocity := Vector2.ZERO
var attack_timer := 0.0
var attack: Dictionary = {}
var attack_timing := 0.0
var impact_fired := false
var queued_attack := ""
var dodge_timer := 0.0
var dodge_direction := Vector2.RIGHT
var hit_timer := 0.0
var combo := 0
var combo_timer := 0.0
var glow := 0.0
var duplicate_phase := 0.0
var visual: AnimatedSprite2D
var visual_state: StringName = &""

func _ready() -> void:
	visual = get_node_or_null("Visual") as AnimatedSprite2D
	if visual != null:
		visual.sprite_frames = SpriteLibrary.player()
		_set_visual(&"idle")

func reset_for_show() -> void:
	reader = ComboReader.new()
	abilities = AbilitySystem.new()
	velocity = Vector2.ZERO
	attack_timer = 0.0
	attack = {}
	attack_timing = 0.0
	impact_fired = false
	queued_attack = ""
	dodge_timer = 0.0
	hit_timer = 0.0
	combo = 0
	combo_timer = 0.0
	glow = 0.0
	_set_visual(&"idle", true)
	queue_redraw()

func tick(delta: float) -> void:
	abilities.tick(delta)
	combo_timer = maxf(combo_timer - delta, 0.0)
	if combo_timer == 0.0:
		combo = 0
	hit_timer = maxf(hit_timer - delta, 0.0)
	glow = maxf(glow - delta * 2.5, 0.0)
	duplicate_phase += delta * 7.0
	if dodge_timer > 0.0:
		dodge_timer -= delta
		position += dodge_direction * DODGE_SPEED * delta
		_clamp_to_arena()
		_sync_visual()
		queue_redraw()
		return
	_update_attack(delta)
	var movement := _movement_input()
	if movement != Vector2.ZERO:
		facing = signf(movement.x) if movement.x != 0.0 else facing
	var speed := WALK_SPEED * (0.45 if attack_timer > 0.0 else 1.0)
	velocity = velocity.move_toward(movement * speed, WALK_SPEED * 8.0 * delta)
	position += velocity * delta
	_clamp_to_arena()
	_sync_visual()
	queue_redraw()

func _sync_visual() -> void:
	if visual == null:
		return
	visual.flip_h = facing < 0.0
	if hit_timer > 0.0:
		visual.modulate = Color("ff8bc9")
	else:
		visual.modulate = Color.WHITE
	if dodge_timer > 0.0:
		_set_visual(&"dodge")
	elif attack_timer > 0.0:
		_set_visual(&"attack")
	elif velocity.length_squared() > 900.0:
		_set_visual(&"walk")
	else:
		_set_visual(&"idle")

func _set_visual(next_state: StringName, restart := false) -> void:
	if visual == null or (visual_state == next_state and not restart):
		return
	visual_state = next_state
	visual.play(next_state)
	if restart:
		visual.set_frame_and_progress(0, 0.0)

func handle_input(event: InputEvent, timing: float, song_time: float, crowd: float) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_U:
		_try_ability("stun", crowd)
		return
	if event.keycode == KEY_I:
		_try_ability("grave", crowd)
		return
	if event.keycode == KEY_O:
		_try_ability("duplo", crowd)
		return
	if event.keycode == KEY_L or event.keycode == KEY_SHIFT:
		reader.record("D", song_time)
		_request_dodge()
		return
	if event.keycode == KEY_J or event.keycode == KEY_K:
		var action := "J" if event.keycode == KEY_J else "K"
		var combo_attack := reader.record(action, song_time)
		var attack_id := combo_attack
		if attack_id.is_empty():
			attack_id = "light" if action == "J" else "heavy"
		if combo_attack == "dash" and dodge_timer > 0.0:
			dodge_timer = 0.0
		_request_attack(attack_id, timing)
		_emit_timing(timing)

func _try_ability(id: String, crowd: float) -> void:
	if abilities.cast(id, combo, crowd):
		emit_signal("ability_cast", id)

func _emit_timing(timing: float) -> void:
	var label := "FORA"
	if timing >= 0.99:
		label = "PERFECT"
	elif timing > 0.0:
		label = "GOOD"
	emit_signal("timing_judged", label, timing)

func _movement_input() -> Vector2:
	var direction := Vector2.ZERO
	direction.x = float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	direction.y = float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	return direction.normalized()

func _clamp_to_arena() -> void:
	position.x = clampf(position.x, ARENA.position.x, ARENA.end.x)
	position.y = clampf(position.y, ARENA.position.y, ARENA.end.y)

func _request_attack(id: String, timing: float) -> void:
	if hit_timer > 0.0:
		return
	if attack_timer > 0.0:
		queued_attack = id
		return
	if dodge_timer > 0.0 and id != "dash":
		return
	attack = AttackCatalog.attack(id)
	attack_timing = timing
	attack_timer = float(attack.duration)
	impact_fired = false
	if visual != null:
		var frame_count := visual.sprite_frames.get_frame_count(&"attack")
		visual.sprite_frames.set_animation_speed(&"attack", float(frame_count) / attack_timer)
	_set_visual(&"attack", true)

func _request_dodge() -> void:
	if attack_timer > 0.0 or dodge_timer > 0.0 or hit_timer > 0.0:
		return
	var direction := _movement_input()
	if direction == Vector2.ZERO:
		direction = Vector2(facing, 0.0)
	dodge_direction = direction.normalized()
	dodge_timer = 0.18
	glow = 1.0

func _update_attack(delta: float) -> void:
	if attack_timer <= 0.0:
		return
	attack_timer -= delta
	if not impact_fired and attack_timer <= float(attack.duration) - float(attack.impact):
		impact_fired = true
		emit_signal("attack_impact", attack, attack_timing, abilities.damage_multiplier(), abilities.duplo_time > 0.0)
	if attack_timer <= 0.0 and not queued_attack.is_empty():
		var next_attack := queued_attack
		queued_attack = ""
		_request_attack(next_attack, attack_timing)

func register_landed_hit(timing: float) -> void:
	combo += 1
	combo_timer = 1.8
	glow = maxf(glow, timing)

func collect_notes(amount: int) -> void:
	abilities.add_notes(amount)
	glow = 1.0

func take_hit() -> bool:
	if dodge_timer > 0.0 or hit_timer > 0.0:
		return false
	hit_timer = 0.34
	combo = 0
	combo_timer = 0.0
	return true

func public_is_guarded() -> bool:
	return abilities.public_guarded()

func _draw() -> void:
	if abilities.duplo_time > 0.0:
		var ghost_offset := Vector2(sin(duplicate_phase) * 28.0, 3.0)
		if visual != null and visual.sprite_frames != null:
			draw_set_transform(ghost_offset, 0.0, Vector2.ONE)
			var ghost_texture := visual.sprite_frames.get_frame_texture(visual.animation, visual.frame)
			if ghost_texture != null:
				draw_texture_rect(ghost_texture, Rect2(-81, -195, 162, 215), false, Color("8d7dff", 0.26))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if abilities.grave_time > 0.0:
		draw_arc(Vector2.ZERO, 61, 0.0, TAU, 24, Color("ffad4d"), 4.0)
