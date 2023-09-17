extends CharacterBody2D

const animation_dead_zone = 0.1

@export var movement_speed = 20.0
@export var hp = 10
@export var knockback_recovery_time = 3.5 # seconds
@export var experience = 1
@export var gem_value = 1
@export var damage = 1


## If the sprite has only a single frame, do a custom animation to simulate movement.
@export var single_frame_mode = false
var single_frame_count = 0
var sprite_walk_flip = false

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var hit_box = $HitBox
@onready var sound_hit = $SoundHit

# global reference
@onready var loot_base = get_tree().get_first_node_in_group("loot_root")
@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("player")
var death_animation = preload("res://Enemy/Effects/explosion/explosion.tscn")
var gem = preload("res://Items/Gem/gem.tscn")


signal remove_from_array(object)

var knockback = Vector2.ZERO

func _ready():
	if single_frame_mode:
		$SingleFrameMoveTimer.start()
	else:
		animation_player.play("walk")
	hit_box.damage = damage

## we don't use delta because move_and_slide() already uses it
func _process(_delta):
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
	if single_frame_mode:
		sprite.flip_h = sprite_walk_flip
	else:
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

func death(killed_by_player=true):
	if killed_by_player:
		player.get_experience(experience)
		_drop_experience_gem()
	emit_signal("remove_from_array", self)
	_add_death_animation()
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
	var new_gem = gem.instantiate()
	new_gem.global_position = global_position
	new_gem.value = gem_value
	loot_base.call_deferred("add_child", new_gem) # same as enemy death

func _single_frame_movement():
	if single_frame_count == 0:
		sprite_walk_flip = false
	elif single_frame_count == 1:
		sprite_walk_flip = true
	single_frame_count = (single_frame_count + 1) % 2

func _on_single_frame_move_timer_timeout():
	_single_frame_movement()

func apply_data(enemy_data: Enemy_data):
	hp = enemy_data.hp
	damage = enemy_data.damage
	movement_speed = enemy_data.movement_speed
	knockback_recovery_time = enemy_data.knockback_recovery
	experience = enemy_data.experience
	gem_value = enemy_data.gem_value
	apply_scale(Vector2(enemy_data.size, enemy_data.size))
