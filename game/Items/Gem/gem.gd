extends Area2D

@export var value = 1

var sprite_green = preload("res://Items/Gem/Textures/Gem_green.png")
var sprite_blue = preload("res://Items/Gem/Textures/Gem_blue.png")
var sprite_red = preload("res://Items/Gem/Textures/Gem_red.png")

var target = null

# add a bounce when collecting the gwm, gem moves away initially then gets collected
const SPEED_COLLECT_INITIAL_BOUNCE_BACK = -1
var speed = SPEED_COLLECT_INITIAL_BOUNCE_BACK

@onready var sprite : Sprite2D = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound_collect = $SoundCollect

func _ready():
	_set_gem_color(value)

## Set the color of the gem based on how much  points the player gets.
func _set_gem_color(value_points):
	if value_points < 5:
		return
	elif value_points < 25:
		sprite.texture = sprite_blue
	else:
		sprite.texture = sprite_red

func _physics_process(delta):
	# Target is the player
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta # Accelerate towards the player

## When the player collets the gem, they call this method to collect it.
func collect():
	sound_collect.play()
	_hide_gem()
	return

## Hide the game, by making it not visible and disabling it.
func _hide_gem():
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false

## After the sound_collect is played, we destroy the gem.
## This is so collect() can be returned to the player collecting it.
func _on_sound_collect_finished():
	queue_free()
