extends Area2D
class_name EntityHit

@onready var player = get_tree().get_first_node_in_group("player")
@onready var life_time_timer = $LifeTimeTimer
@onready var on_hit_attacks = $OnHitAttacks
var on_hit_attack_sequence: Array

@export var enemy_detect_area : Area2D

var entity_hit: EntityHit # stores the hit properties
@export var debug_name: String

# Hit properties
# TODO use attack_properties instead?
@export var attack_properties : SpellCardEffect # unused right now
@export var speed : float = 100.0
@export var damage = 5
@export var knockback_amount = 100
@export var attack_size = 1.0
@export var attack_hp = 1
@export var crit_chance: float
@export var crit_damage: float
@export var lifetime : float
@export var hit_movement_type: SpellCardEffect.HIT_MOVEMENT_TYPE
@export var hit_behaviour_type: SpellCardEffect.HIT_BEHAVIOUR_TYPE
@export var on_hit_spellcards : Array


## Hit internal properties
var facing_vector = Vector2.ZERO # angle the projectile is aiming towards
var starting_pos = Vector2.ZERO # Starting position
var angle = Vector2.ZERO # final angle to shoot at
var target: Node = null # Target for aiming/homing towards

## homing behaviour
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var steer_force = 50.0

## Tornado behaviour
var last_movement = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO
var tornado_tween: Tween = null
var tornado_aimed_more = true
var tornado_eval_time = 1.0/30.0
var tornado_flip_time = 2
var timer = 0.0 # Timer for the tornado

signal remove_from_array(object)

## Called when the node enters the scene tree for the first time.
func _ready():
	if lifetime > 0:
		life_time_timer.wait_time = lifetime
		life_time_timer.start()
	
	## Set the angle
	angle = global_position.direction_to(starting_pos)
	_set_movement_type()
	_behaviour_type_setup()
	
	for spellcard in on_hit_spellcards:
		if spellcard is SpellCardEffect:
			_add_attack(spellcard)
			pass

func set_target(target_obj):
	self.target = target_obj
#	if target != null:
#		print("%s - %s" % [debug_name, self.target.name])
#	else:
#		print("%s - %s" % [debug_name, "null"])

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_behaviour_type_process(delta)
	_do_behaviour_process(delta)

## Called by HurtBox, when it hits an enemy.
## When the ice spear hits the enemy, remove this projectile.
func enemy_hit(charge = 1):
	attack_hp -= charge
	_on_hit_attacks()

	if attack_hp <= 0:
		_delete_self()

func _delete_self():
	emit_signal("remove_from_array", self)
	queue_free()

func _on_life_time_timer_timeout():
	_delete_self()

func _add_attack(spellcard_effect):
	var attack_object = load(SpellCardEffect.get_attack_type(spellcard_effect.attack_type))
	var attack_instance = attack_object.instantiate()
	attack_instance.setup_attack(spellcard_effect, Callable(self, "get_start_position"), Callable(self, "get_direction"))
	
	var entity_attack = EntityAttack.new()
	entity_attack.attack_properties = spellcard_effect
#	attack_instance.entity_attack = entity_attack
	
	on_hit_attacks.add_child(attack_instance)
	on_hit_attack_sequence.append(attack_instance)
	return attack_instance

func _on_hit_attacks():
	for attack in on_hit_attack_sequence:
		attack.do_attack()
	pass

func get_start_position():
	return global_position

func get_direction():
	return angle



# --- movement types ---

func _set_movement_type():
	# Set the movement type
	if hit_movement_type == SpellCardEffect.HIT_MOVEMENT_TYPE.STRAIGHT_LINE:
		_straight_line_movement_setup()
	elif hit_movement_type == SpellCardEffect.HIT_MOVEMENT_TYPE.PING_PONG_PATH:
		_tornado_movement_setup()

func _straight_line_movement_setup():
	# the ice spear is current 45 degrees, so we compensate by adding 135 degrees
	# this way, the ice spear is equal to Vector(1, 0)
	# and faces right
	angle = facing_vector.normalized()
	rotation = angle.angle()
#	rotation = angle.angle() + deg_to_rad(135)

	# a small animation where the ice spear starts off small and grows into
	# its full size.
	# Tween interpolates between two states, shifting from oen to the other.
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _tornado_movement_setup():
	# Normalize the vector so we get the direction
	last_movement = facing_vector.normalized()
	
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	## Get the less and more vectors, which are the min and max of the wave movement
	var ideal_move_to_less = Vector2(-last_movement.y, last_movement.x)
	var ideal_move_to_more = Vector2(last_movement.y, -last_movement.x)
	## We add last_movement, since that is the original vector we move the wave towards
	## So ideal_move_to_* is the oscillation, and the last_movement is the original vector.
	## the combined vector is the movement of the projectile.
	## The 500 is to set the long distance min & max targets to aim towards.
	move_to_less = global_position + (last_movement + ideal_move_to_less) * 500
	move_to_more = global_position + (last_movement + ideal_move_to_more) * 500

	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	## The tornado starts off small, and grows to its full size.
	## also, it starts off slow and accelerates over time to its full speed.
	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed = speed
	speed = speed/5
	initial_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initial_tween.play()
	
	tornado_tween = create_tween()
	var set_angle = randi_range(0, 1)
	tornado_aimed_more = (set_angle == 0)
	
	
	if set_angle == 1:
		angle = angle_less
		tornado_tween.tween_property(self, "angle", angle_more, 2)
		tornado_tween.tween_property(self, "angle", angle_less, 2)
		tornado_tween.tween_property(self, "angle", angle_more, 2)
		tornado_tween.tween_property(self, "angle", angle_less, 2)
		tornado_tween.tween_property(self, "angle", angle_more, 2)
		tornado_tween.tween_property(self, "angle", angle_less, 2)
	else:
		angle = angle_more
		tornado_tween.tween_property(self, "angle", angle_less, 2)
		tornado_tween.tween_property(self, "angle", angle_more, 2)
		tornado_tween.tween_property(self, "angle", angle_less, 2)
		tornado_tween.tween_property(self, "angle", angle_more, 2)
		tornado_tween.tween_property(self, "angle", angle_less, 2)
		tornado_tween.tween_property(self, "angle", angle_more, 2)
	tornado_tween.play()
	
func _do_behaviour_process(delta):
	if hit_movement_type == SpellCardEffect.HIT_MOVEMENT_TYPE.STRAIGHT_LINE:
		pass
	elif hit_movement_type == SpellCardEffect.HIT_MOVEMENT_TYPE.PING_PONG_PATH:
		_tornado_movement(delta)

## Unused
func _tornado_movement(delta):
#	timer += delta
#	while timer >= tornado_flip_time:
#		# Normalize the vector so we get the direction
#		last_movement = facing_vector.normalized()
#
#		var move_to_less = Vector2.ZERO
#		var move_to_more = Vector2.ZERO
#		## Get the less and more vectors, which are the min and max of the wave movement
#		var ideal_move_to_less = Vector2(-last_movement.y, last_movement.x)
#		var ideal_move_to_more = Vector2(last_movement.y, -last_movement.x)
#		## We add last_movement, since that is the original vector we move the wave towards
#		## So ideal_move_to_* is the oscillation, and the last_movement is the original vector.
#		## the combined vector is the movement of the projectile.
#		## The 500 is to set the long distance min & max targets to aim towards.
#		move_to_less = global_position + (last_movement + ideal_move_to_less) * 500
#		move_to_more = global_position + (last_movement + ideal_move_to_more) * 500
#
#		angle_less = global_position.direction_to(move_to_less)
#		angle_more = global_position.direction_to(move_to_more)
#
#		## Reset the tween
#		if tornado_tween:
#			tornado_tween.kill()
#		tornado_tween = create_tween()
#
#		## Play the tween
#		if tornado_aimed_more:
#			tornado_tween.tween_property(self, "angle", angle_more, tornado_flip_time)
#		else:
#			tornado_tween.tween_property(self, "angle", angle_less, tornado_flip_time)
#		tornado_tween.play()
#
#		tornado_aimed_more = !tornado_aimed_more
#		timer -= 2
	pass

# --- hit_behaviour_type settings ---

func _behaviour_type_setup():
	if hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOUR_TYPE.NONE:
		pass
	elif hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOUR_TYPE.HOMING:
		_homing_behaviour_setup()
	elif hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOUR_TYPE.ACCELERATING_HOMING:
		_homing_behaviour_setup()
#		velocity = Vector2.ZERO
	elif hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOUR_TYPE.DECELERATING_HOMING:
		_homing_behaviour_setup()

func _homing_behaviour_setup():
	angle = facing_vector.normalized()
	rotation = angle.angle()
	position = starting_pos
	velocity = transform.x * speed

func _behaviour_type_process(delta):
	if hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOUR_TYPE.NONE:
		_straight_line_behaviour(delta)
	elif hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOUR_TYPE.HOMING:
		_homing_process(delta)
	elif hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOUR_TYPE.ACCELERATING_HOMING:
		_accelerating_homing_process(delta)
	elif hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOUR_TYPE.DECELERATING_HOMING:
		_decelerating_homing_process(delta)
	else:
		# Default goes in a straight line
		_straight_line_behaviour(delta)

func _straight_line_behaviour(delta):
	position += angle * speed * delta

func _homing_process(delta, limit_speed=true):
	acceleration += seek()
	velocity += acceleration * delta
	if limit_speed:
		velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	position += velocity * delta

func seek():
	var steer = Vector2.ZERO
	if is_instance_valid(target) and target is Node:
		var desired = (target.global_position - global_position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	else:
		pass # should never happen
	return steer

func _accelerating_homing_process(delta):
	if target != null:
		var angle_to_target = global_position.direction_to(target.global_position)
		angle += angle_to_target
	rotation = angle.angle()
	position += angle * speed * delta * delta

func _decelerating_homing_process(delta):
	velocity -= velocity * delta
	if velocity.length() < 0:
		velocity = Vector2.ZERO
	rotation = velocity.angle()
	position += velocity * delta

# --- 


