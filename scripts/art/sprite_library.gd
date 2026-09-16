class_name SpriteLibrary
extends RefCounted

const FRAME_COUNT := 4


static func player() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_animation(frames, &"idle", "res://assets/player/sprites/idle/edriel_idle_%02d.png", 7.0, true)
	_add_animation(frames, &"walk", "res://assets/player/sprites/walk/edriel_walk_%02d.png", 10.0, true)
	_add_animation(frames, &"attack", "res://assets/player/sprites/attack/edriel_attack_%02d.png", 12.0, false)
	_add_animation(frames, &"dodge", "res://assets/player/sprites/dodge/edriel_dodge_%02d.png", 14.0, false)
	return frames


static func rival(kind: int) -> SpriteFrames:
	var actor := "neon_runner" if kind % 2 == 0 else "chrome_heavy"
	var root := "res://assets/enemies/%s/sprites" % actor
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_animation(frames, &"idle", root + "/idle/" + actor + "_idle_%02d.png", 6.0, true)
	_add_animation(frames, &"walk", root + "/walk/" + actor + "_walk_%02d.png", 9.0, true)
	_add_animation(frames, &"attack", root + "/attack/" + actor + "_attack_%02d.png", 11.0, false)
	_add_animation(frames, &"defeat", root + "/defeat/" + actor + "_defeat_%02d.png", 8.0, false)
	return frames


static func crowd(member: int) -> SpriteFrames:
	var actor := "crowd_%s" % char(97 + posmod(member, 4))
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_animation(frames, &"dance", "res://assets/crowd/%s/dance/%s_dance_%%02d.png" % [actor, actor], 5.0 + float(member % 3), true)
	return frames


static func _add_animation(frames: SpriteFrames, animation: StringName, pattern: String, speed: float, loop: bool) -> void:
	frames.add_animation(animation)
	frames.set_animation_speed(animation, speed)
	frames.set_animation_loop(animation, loop)
	for frame_number in range(1, FRAME_COUNT + 1):
		var texture := load(pattern % frame_number) as Texture2D
		if texture != null:
			frames.add_frame(animation, texture)
