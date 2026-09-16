class_name StreetCrowd
extends Node2D

const CROWD_COUNT := 12

var crowd_energy := 55.0
var pulse := 0.0
var act_color := Color("35e6ff")
var members: Array[AnimatedSprite2D] = []

func _ready() -> void:
	for index in CROWD_COUNT:
		var member := AnimatedSprite2D.new()
		member.sprite_frames = SpriteLibrary.crowd(index)
		member.animation = &"dance"
		member.offset = Vector2(0.0, -208.0)
		member.scale = Vector2.ONE * (0.25 + float(index % 3) * 0.015)
		member.position = Vector2(155.0 + float(index) * 148.0, 660.0 + float(index % 2) * 18.0)
		member.flip_h = index % 3 == 1
		member.frame = index % 4
		member.play()
		members.append(member)
		add_child(member)

func present(next_energy: float, next_pulse: float, next_color: Color) -> void:
	crowd_energy = next_energy
	pulse = next_pulse
	act_color = next_color
	var intensity := 0.72 + crowd_energy * 0.0028
	var beat_scale := 1.0 + pulse * 0.035
	for index in members.size():
		var member := members[index]
		var base_scale := 0.25 + float(index % 3) * 0.015
		member.speed_scale = 0.72 + crowd_energy * 0.008
		member.scale = Vector2.ONE * base_scale * beat_scale
		member.modulate = Color.WHITE.lerp(act_color, 0.06 * pulse)
		member.modulate.a = intensity
