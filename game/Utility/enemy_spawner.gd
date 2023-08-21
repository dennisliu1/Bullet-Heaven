extends Node2D

@export var spawns: Array[Spawn_info] = []
# The current time from when the run started.
@export var time = 0

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

@onready var timer = $Timer

const SPAWN_WINDOW_BORDER_AREA_MIN = 1.1
const SPAWN_WINDOW_BORDER_AREA_MAX = 1.4

signal changetime(time)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Notify the player the time is updated.
	connect("changetime", Callable(player, "change_time"))
	
	# load data from json instead
	var loaded_data : Array[Spawn_info] = Global.get_enemy_spawn_data()
	spawns.append_array(loaded_data)
	pass

func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	for enemy_spawn in enemy_spawns:
		if enemy_spawn.time_start <= time and time <= enemy_spawn.time_end and _delay_spawn(enemy_spawn):
			_spawn_enemies(enemy_spawn)

	# Notify the UI the timer has been updated.
	emit_signal("changetime", time)

## Delay the spawn based on the spawn-delay.
## Returns true once the delay is over.
func _delay_spawn(enemy_spawn):
	# Wait for a delay time before spawning enemies in.
	if enemy_spawn.spawn_delay_counter < enemy_spawn.enemy_spawn_delay:
		enemy_spawn.spawn_delay_counter += 1
		return false
	else:
		enemy_spawn.spawn_delay_counter = 0
		return true

## Spawn a number of enemies as part of a wave.
func _spawn_enemies(enemy_spawn):
	var counter = 0
	while counter < enemy_spawn.enemy_num:
		_spawn_enemy(enemy_spawn.enemy)
		counter += 1

## Spawn a single enemy
func _spawn_enemy(new_enemy):
	var enemy_instance = new_enemy.instantiate()
	enemy_instance.global_position = get_random_position()
	add_child(enemy_instance)

## Get a random position just outside the game viewport, so the enemy spawns
## outside the viewable area.
## Steps:
## 1. Get how far away from the screen to spawn the enemy
## 2. Pick a random side of the screen
## 3. randomly get the final position of the spawn, on that side.
func get_random_position():
	# Get a bounding box, which is the lines where the enemy will spawn.
	# The rect lines are between SPAWN_WINDOW_BORDER_AREA_MIN and SPAWN_WINDOW_BORDER_AREA_MAX
	# So if the min and max is 1.1 and 1.4, the bounding box will randomly
	# pick a value between 1.1x and 1.4x of the viewport screen.
	# That value, for x and y, gets used to create the box.
	var vpr = get_viewport_rect().size * randf_range(SPAWN_WINDOW_BORDER_AREA_MIN, SPAWN_WINDOW_BORDER_AREA_MAX) # viewport rect
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	
	# Pick a random side of the bounding rect.
	var pos_side = ["up", "down", "left", "right"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right

	# Using the random side
	# randomly get the final position along that side of the rect.
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)

# --- stage ---














