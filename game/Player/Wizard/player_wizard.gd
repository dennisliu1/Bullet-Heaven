extends CharacterBody2D

# player game variables
var movement_speed = 80.0 # 80 pixels per second moved

# player base properties
@export var hp = 80

# tracking variables
var last_movement = Vector2.UP

# references
@onready var sprite = $Sprite2D
@onready var walk_timer = $WalkTimer

# attacks

## ice spear
@onready var attack_container = $Attack
#var icespear_ammo = 1
#var icespear_baseammo = 1
#var icespear_attackspeed = 1.5
#var icespear_level = 1
#@onready var icespear_timer = $Attack/IceSpearTimer
#@onready var icespear_attack_timer = $Attack/IceSpearTimer/IceSpearAttackTimer

var ice_spear = preload("res://Player/Attacks/Ice Spear/ice_spear.tscn")

# enemy related
var enemy_close = []




func _ready():
	attack()

func attack():
#	if icespear_level > 0:
#		icespear_timer.wait_time = icespear_attackspeed
#		if icespear_timer.is_stopped():
#			icespear_timer.start()
	pass

func _physics_process(_delta): # 60 FPS
	movement()

func movement():
	# get_action_strength return 0 or 1, if it is pressed = 1
	# so left = 1 - 0 = 1
	var x_move = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_move = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var move_direction = Vector2(x_move, y_move)

	if move_direction != Vector2.ZERO:
		last_movement = move_direction
		_animate_walk_frame()

	# change the sprite direction.
	_change_sprite_direction(move_direction)

	# normalize to get the vector direction, handles diagonal length properly
	# Multiply by delta to update based on current frame rate.
	# move_and_slide already multiplies by delta, so we don't need to use it in velocity.
	velocity = move_direction.normalized() * movement_speed
	move_and_slide()


## Manually animate the walk frames.
## Needs this because the player can pause at any time,
## where the player should pause the frame.
func _animate_walk_frame():
	if walk_timer.is_stopped():
		if sprite.frame >= sprite.hframes - 1: # reached the end frame, reset
			sprite.frame = 0
		else:
			sprite.frame += 1
#		$AnimationPlayer.play("walk")
		walk_timer.start()

## Change the direction the sprite faces, depending on the move direction.
func _change_sprite_direction(move_direction):
	if move_direction.x > 0:
		sprite.flip_h = true
	elif move_direction.x < 0:
		sprite.flip_h = false


func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	print(hp)

#	hp -= clamp(damage - armor, 1.0, 999)
#	health_bar.max_value = maxhp
#	health_bar.value = hp
#	if hp <= 0:
#		death()


#func _on_ice_spear_timer_timeout():
#	icespear_ammo += icespear_baseammo
#	icespear_attack_timer.start()
#
#
#func _on_ice_spear_attack_timer_timeout():
#	if icespear_ammo > 0:
#		var icespear_attack = ice_spear.instantiate()
#		icespear_attack.position = position
#		icespear_attack.target = get_random_target()
##		icespear_attack.level = icespear_level
#		add_child(icespear_attack)
#		icespear_ammo -= 1
#		if icespear_ammo > 0:
#			icespear_attack_timer.start()
#		else:
#			icespear_attack_timer.stop()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP # TODO shoot at the last target vector

func _on_enemy_detect_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detect_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func set_equipped_item(equipment_data, index):
	if equipment_data is EquipmentData:
		var equipped_item = attack_container.get_child(index)
		equipped_item.set_equipped_item(equipment_data)
	else:
		remove_equipped_item(index)

func remove_equipped_item(index):
	var equipped_item = attack_container.get_child(index)
	equipped_item.remove_equipped_item()

## deprecated, not used
#func add_attack(attack_instance, index):
#	var equipped_item = attack_container.get_child(index)
#	equipped_item.add_child(attack_instance)

func add_attack_by_spellcard_effect(spellcard_effect, index):
	var equipped_item = attack_container.get_child(index)
	equipped_item.add_spellcard_effect(spellcard_effect)

func remove_spellcard_effect(spellcard_effect, index):
	var equipped_item = attack_container.get_child(index)
	equipped_item.remove_spellcard_effect(spellcard_effect)







