extends CharacterBody2D

const animation_dead_zone = 0.1

@export var movement_speed = 20.0
@export var hp = 10
@export var knockback_recovery_time = 3.5 # seconds
@export var experience = 1
@export var damage = 1

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var hit_box = $HitBox
@onready var sound_hit = $SoundHit

# global reference
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("player")
var death_animation = preload("res://Enemy/Effects/explosion/explosion.tscn")
var exp_gem = preload("res://Items/ExperienceGem/experience_gem.tscn")


signal remove_from_array(object)

var knockback = Vector2.ZERO

func _ready():
	animation_player.play("walk")
	hit_box.damage = damage

func _physics_process(_delta):
	# gradually reduces the knockback to zero, based on recovery
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery_time)

	# Move towards player
	var move_direction = global_position.direction_to(player.global_position)

	# change the sprite direction.
	_change_sprite_direction(move_direction)

	velocity = move_direction * movement_speed
	velocity += knockback
	move_and_slide()

## Change the direction the sprite faces, depending on the move direction.
func _change_sprite_direction(move_direction):
	if move_direction.x > 0:
		sprite.flip_h = true
	elif move_direction.x < 0:
		sprite.flip_h = false

func _on_hurt_box_hurt(damage_amount, angle, knockback_amount):
	hp -= damage_amount
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		sound_hit.play()

func death():
	emit_signal("remove_from_array", self)
	_add_death_animation()
	_drop_experience_gem()
	queue_free() # destroy enemy

func _add_death_animation():
	var enemy_death = death_animation.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	# We free the enemy right after, so if we add it directly,
	# it causes problems.
	# Adding it as a deferred call gets around the issue.
	# TODO: should refactor out get_parent()
	get_parent().call_deferred("add_child", enemy_death) 

func _drop_experience_gem():
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem) # same as enemy death











