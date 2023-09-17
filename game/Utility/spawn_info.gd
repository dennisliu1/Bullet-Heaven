extends Resource

class_name Spawn_info

@export var time_start: int
@export var time_end: int
@export var enemy: String
@export var enemy_min: int
@export var enemy_num: int
@export var enemy_spawn_delay: int

var spawn_delay_counter = 0
var enemy_count = 0

func enemy_died():
	enemy_count -= 1



