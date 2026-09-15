class_name ShowTimeline
extends RefCounted

const LENGTH := 165.6
const ACTS := [
	{"start": 0.0, "end": 19.0, "name": "CHEGADA", "rivals": 1, "color": Color("35e6ff")},
	{"start": 19.0, "end": 38.0, "name": "A RODA ABRE", "rivals": 2, "color": Color("6f73ff")},
	{"start": 38.0, "end": 78.0, "name": "PRIMEIRO REFRÃO", "rivals": 3, "color": Color("ff3bac")},
	{"start": 78.0, "end": 104.0, "name": "CONTATO", "rivals": 3, "color": Color("ffad4d")},
	{"start": 104.0, "end": 129.0, "name": "SEGUNDO REFRÃO", "rivals": 4, "color": Color("ff3bac")},
	{"start": 129.0, "end": 153.0, "name": "ÚLTIMA LUTA", "rivals": 6, "color": Color("ff3bac")},
	{"start": 153.0, "end": 165.6, "name": "FIM", "rivals": 0, "color": Color("ffad4d")}
]

const LYRICS := [
	[0.0, 4.0, ""], [4.0, 8.0, "hey"], [8.0, 19.0, "hey"],
	[19.0, 24.0, "hoje acordei feliz, porque ontem você me ligou"],
	[24.0, 29.0, "com você quase tudo é bom, a parte ruim é se despedir"],
	[29.0, 34.0, "já que tu vai partir, aproveita e me leva daqui"],
	[34.0, 38.0, "não temos tempo ruim, é só você pedir"],
	[38.0, 47.0, "pré-refrão"], [47.0, 56.0, "e eu vou perder, perder, pra você ganhar, babe"],
	[56.0, 68.0, "e eu vou querer saber tudo sobre você, yeh"],
	[68.0, 78.0, "olhos que não me deixam parar"], [78.0, 87.0, "de tanto suspirar, yeah"],
	[87.0, 104.0, "eu preciso de contato"], [104.0, 113.0, "e eu vou perder, perder, pra você ganhar, babe"],
	[113.0, 129.0, "sobre você"], [129.0, 153.0, "heh, heh, heh"],
	[153.0, 165.6, "fim lento"]
]

func act_at(song_time: float) -> Dictionary:
	for act: Dictionary in ACTS:
		if song_time >= float(act.start) and song_time < float(act.end):
			return act
	return ACTS.back()

func is_outro(song_time: float) -> bool:
	return song_time >= 153.0

func lyric_at(song_time: float) -> String:
	for cue: Array in LYRICS:
		if song_time >= float(cue[0]) and song_time < float(cue[1]):
			return str(cue[2])
	return ""
