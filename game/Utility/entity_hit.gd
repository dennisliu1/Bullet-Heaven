extends Area2D
class_name EntityHit

@onready var player = get_tree().get_first_node_in_group("player")
@onready var life_time_timer = $LifeTimeTimer
@onready var on_hit_attacks = $OnHitAttacks
var on_hit_attack_sequence: Array

@export var enemy_detect_area : Area2D

var entity_hit: EntityHit # stores the hit properties


# Hit properties
# TODO use attack_properties instead?
@export var attack_properties : SpellCardEffect # unused right now
@export var speed : float = 100.0
@export var damage = 5
@export var knockback_amount = 100
@export var attack_size = 1.0
@export var attack_hp = 1
@export var lifetime : float
@export var hit_behaviour_type: SpellCardEffect.HIT_SPAWN_TYPE
@export var on_hit_spellcards : Array


## Hit internal properties
var target = Vector2.ZERO
var angle = Vector2.ZERO

## Tornado behavior
var last_movement = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO

signal remove_from_array(object)

## Called when the node enters the scene tree for the first time.
func _ready():
	if lifetime > 0:
		life_time_timer.wait_time = lifetime
		life_time_timer.start()
	
	
	angle = global_position.direction_to(target)
	for spellcard in on_hit_spellcards:
		if spellcard is SpellCardEffect:
			_add_attack(spellcard)
			pass
	
	if hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOR_TYPE.STRAIGHT_LINE:
		# the ice spear is current 45 degrees, so we compensate by adding 135 degrees
		# this way, the ice spear is equal to Vector(1, 0)
		# and faces right
		rotation = angle.angle() + deg_to_rad(135)
	
		# a small animation where the ice spear starts off small and grows into
		# its full size.
		# Tween interpolates between two states, shifting from oen to the other.
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.play()
	elif hit_behaviour_type == SpellCardEffect.HIT_BEHAVIOR_TYPE.WAVE_PATTERN:
		_tornado_behavior()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += angle * speed * delta

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

func _tornado_behavior():
	last_movement = player.last_movement
	
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1,-0.25), last_movement.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * 500
		Vector2.RIGHT, Vector2.LEFT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1,-0.25)) * 500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * 500
		Vector2(1,1), Vector2(1,-1), Vector2(-1, 1), Vector2(-1,-1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * 500
	
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	var final_speed = speed
	speed = speed/5
	initial_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initial_tween.play()
	
	var tween = create_tween()
	var set_angle = randi_range(0, 1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
	else:
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
	tween.play()




