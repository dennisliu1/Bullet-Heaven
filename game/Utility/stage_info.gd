extends Node

class_name Stage_info

enum MUSIC_STATE {CONTINUE, END}

@export var stage_name: String
@export var time_length: int
@export var music: Resource
@export var music_state: MUSIC_STATE
@export var spawns: Array[Spawn_info]

static func get_music_state(music_state: String):
	if music_state == "CONTINUE":
		return MUSIC_STATE.CONTINUE
	elif music_state == "END":
		return MUSIC_STATE.END
	else:
		return MUSIC_STATE.CONTINUE

