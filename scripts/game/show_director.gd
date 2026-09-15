class_name ShowDirector
extends Node2D

const ARENA_SCENE := preload("res://scenes/game/street_arena.tscn")
const PLAYER_SCENE := preload("res://scenes/actors/edriel.tscn")
const RIVAL_SCENE := preload("res://scenes/actors/rival.tscn")
const HUD_SCENE := preload("res://scenes/ui/show_hud.tscn")
const NOTE_SCENE := preload("res://scenes/game/music_note.tscn")
const MAX_NOTES := 12

var timeline := ShowTimeline.new()
var beat_clock := BeatClock.new()
var arena: StreetArena
var player: StreetFighter
var hud: ShowHud
var music: AudioStreamPlayer
var rivals: Array[StreetRival] = []
var notes: Array[MusicNote] = []
var note_pool: Array[MusicNote] = []
var state := "title"
var song_time := 0.0
var fallback_time := 0.0
var crowd := 55.0
var score := 0
var spawn_timer := 0.8
var outro_started := false
var timing_label := ""
var timing_label_timer := 0.0

func _ready() -> void:
	arena = ARENA_SCENE.instantiate()
	player = PLAYER_SCENE.instantiate()
	hud = HUD_SCENE.instantiate()
	player.position = Vector2(960, 770)
	add_child(arena)
	add_child(player)
	add_child(hud)
	for index in range(MAX_NOTES):
		var note: MusicNote = NOTE_SCENE.instantiate()
		note.name = "MusicNotePool%d" % index
		note.collected.connect(_on_note_collected)
		note.expired.connect(_on_note_expired)
		note.deactivate()
		note_pool.append(note)
		add_child(note)
	player.attack_impact.connect(_on_attack_impact)
	player.ability_cast.connect(_on_ability_cast)
	player.timing_judged.connect(_on_timing_judged)
	music = AudioStreamPlayer.new()
	music.stream = load("res://audio/track.wav")
	music.volume_db = -3.0
	add_child(music)
	call_deferred("_present")

func _process(delta: float) -> void:
	if state != "playing":
		_present()
		return
	if music.is_playing():
		song_time = music.get_playback_position()
	else:
		fallback_time += delta
		song_time = fallback_time
	player.tick(delta)
	_update_notes(delta)
	_update_rivals(delta)
	_update_waves(delta)
	if not player.public_is_guarded():
		crowd = clampf(crowd + delta * 0.45, 0.0, 100.0)
	timing_label_timer = maxf(timing_label_timer - delta, 0.0)
	if song_time >= ShowTimeline.LENGTH:
		_finish_show()
	_present()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_F3:
		hud.toggle_diagnostics()
		return
	if state == "title" and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
		_start_show()
		return
	if state == "ending" and event.keycode == KEY_R:
		_reset_show()
		return
	if state == "playing":
		if event.keycode == KEY_ESCAPE:
			music.stream_paused = not music.stream_paused
		elif not music.stream_paused and not timeline.is_outro(song_time):
			player.handle_input(event, beat_clock.quality_at(song_time), song_time, crowd)

func _start_show() -> void:
	state = "playing"
	song_time = 0.0
	fallback_time = 0.0
	crowd = 55.0
	score = 0
	spawn_timer = 0.8
	outro_started = false
	music.stream_paused = false
	music.play()

func _reset_show() -> void:
	_clear_stage()
	player.position = Vector2(960, 770)
	song_time = 0.0
	fallback_time = 0.0
	crowd = 55.0
	score = 0
	spawn_timer = 0.8
	outro_started = false
	state = "title"

func _clear_stage() -> void:
	for rival in rivals:
		if is_instance_valid(rival):
			rival.queue_free()
	rivals.clear()
	notes.clear()
	for note in note_pool:
		note.deactivate()

func _update_waves(delta: float) -> void:
	if timeline.is_outro(song_time):
		_begin_outro()
		return
	var act := timeline.act_at(song_time)
	var target_count: int = int(act.rivals)
	spawn_timer -= delta
	if rivals.size() < target_count and spawn_timer <= 0.0:
		_spawn_rival(rivals.size() % 3)
		spawn_timer = 1.10

func _begin_outro() -> void:
	if outro_started:
		return
	outro_started = true
	_clear_stage()

func _spawn_rival(kind: int) -> void:
	var rival: StreetRival = RIVAL_SCENE.instantiate()
	rival.setup(kind)
	var side := -1.0 if rivals.size() % 2 == 0 else 1.0
	rival.position = player.position + Vector2(side * (320.0 + rivals.size() * 55.0), 65.0 - rivals.size() * 60.0)
	rival.position.x = clampf(rival.position.x, 260.0, 1660.0)
	rival.position.y = clampf(rival.position.y, 560.0, 870.0)
	rival.strike_attempt.connect(_on_rival_strike)
	rival.defeated.connect(_on_rival_defeated)
	rivals.append(rival)
	add_child(rival)

func _update_rivals(delta: float) -> void:
	for index in range(rivals.size() - 1, -1, -1):
		var rival := rivals[index]
		if is_instance_valid(rival):
			rival.tick(delta, player.position)

func _update_notes(delta: float) -> void:
	for index in range(notes.size() - 1, -1, -1):
		var note := notes[index]
		if note.active:
			note.tick(delta, player.position)
		if not note.active and notes.has(note):
			notes.erase(note)

func _on_attack_impact(attack: Dictionary, timing: float, multiplier: int, duplicated: bool) -> void:
	var landed := 0
	var wide := bool(attack.get("wide", false))
	var power := int(attack.power) * multiplier * (2 if duplicated else 1)
	for index in range(rivals.size() - 1, -1, -1):
		var rival := rivals[index]
		if not is_instance_valid(rival):
			continue
		var to_rival: Vector2 = rival.position - player.position
		if not wide and to_rival.x * player.facing <= 0.0:
			continue
		if absf(to_rival.y) > float(attack.area) or to_rival.length() > float(attack.reach):
			continue
		rival.receive_hit(to_rival, power, timing)
		landed += 1
		if timing > 0.0:
			_spawn_note(rival.position, 1, to_rival)
	if landed > 0:
		player.register_landed_hit(timing)
		score += int(100.0 * power * landed * (1.0 + timing))
		crowd = clampf(crowd + 2.5 * landed + timing * 5.0, 0.0, 100.0)
	elif str(attack.id) == "heavy":
		crowd = maxf(crowd - 1.0, 0.0)

func _on_ability_cast(id: String) -> void:
	match id:
		"stun":
			for rival in rivals:
				if is_instance_valid(rival) and rival.position.distance_to(player.position) <= StatusEffects.STUN_RADIUS:
					rival.apply_stun(StatusEffects.stun_duration())
		"grave":
			timing_label = "GRAVE · DANO x3"
			timing_label_timer = 1.2
		"duplo":
			timing_label = "DUPLO · 5 SEGUNDOS"
			timing_label_timer = 1.2

func _on_timing_judged(label: String, _quality: float) -> void:
	timing_label = label
	timing_label_timer = 0.55

func _on_rival_strike(rival: StreetRival) -> void:
	if not is_instance_valid(rival) or rival.position.distance_to(player.position) > rival.attack_range + 35.0:
		return
	if player.take_hit() and not player.public_is_guarded():
		crowd = maxf(crowd - 11.0, 0.0)

func _on_rival_defeated(rival: StreetRival) -> void:
	rivals.erase(rival)
	if is_instance_valid(rival):
		_spawn_note(rival.position, 2, Vector2(randf_range(-1.0, 1.0), -0.5))
		rival.queue_free()
	score += 350
	crowd = clampf(crowd + 10.0, 0.0, 100.0)

func _spawn_note(at: Vector2, amount: int, direction: Vector2) -> void:
	var note: MusicNote
	for pooled_note in note_pool:
		if not pooled_note.active:
			note = pooled_note
			break
	if note == null:
		return
	note.position = at
	note.setup(amount, direction)
	notes.append(note)

func _on_note_collected(note: MusicNote, amount: int) -> void:
	notes.erase(note)
	player.collect_notes(amount)

func _on_note_expired(note: MusicNote) -> void:
	notes.erase(note)

func _finish_show() -> void:
	state = "ending"
	music.stop()

func _rank() -> String:
	if crowd >= 82.0:
		return "VOCÊ TOMOU A RODA · S RANK"
	if crowd >= 58.0:
		return "A RODA FICOU COM VOCÊ · A RANK"
	return "VOCÊ CHEGOU ATÉ O FIM · B RANK"

func _present() -> void:
	var act := timeline.act_at(song_time)
	var pulse := beat_clock.pulse_at(song_time)
	arena.present(crowd, pulse, act.color)
	var label := timing_label if timing_label_timer > 0.0 else ""
	hud.present(state, score, player.combo, crowd, player.abilities.notes, player.abilities.grave_time, player.abilities.duplo_time, str(act.name), pulse, beat_clock.phase_at(song_time), timeline.lyric_at(song_time), label, _rank(), player.abilities.slot_states(player.combo, crowd), not timeline.is_outro(song_time))
