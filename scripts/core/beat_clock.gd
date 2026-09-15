class_name BeatClock
extends RefCounted

const BPM := 104.0
const OFFSET := 0.0
const PERFECT_WINDOW := 0.075
const GOOD_WINDOW := 0.155

func quality_at(song_time: float) -> float:
	var beat_length := 60.0 / BPM
	var phase := fposmod(song_time - OFFSET, beat_length)
	var distance := minf(phase, beat_length - phase)
	if distance <= PERFECT_WINDOW:
		return 1.0
	if distance <= GOOD_WINDOW:
		return 0.55
	return 0.0

func pulse_at(song_time: float) -> float:
	var beat_length := 60.0 / BPM
	var phase := fposmod(song_time - OFFSET, beat_length) / beat_length
	return pow(1.0 - phase, 4.0)

func phase_at(song_time: float) -> float:
	return fposmod(song_time - OFFSET, 60.0 / BPM) / (60.0 / BPM)
