## Attack is an Hit spawner, creating damaging objects to hurt enemies.
## Used inside an Action, which calls Attacks to spawn Hits.
extends Node
class_name EntityAttack

#@export var spellcard_data: SpellCardData
@export var entity_attack : EntityAttack
@export var enemy_detect_area : Area2D

#var hit_object = preload("res://Player/Attacks/Ice Spear/ice_spear.tscn")
var hit_object

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var hit_root = get_tree().get_first_node_in_group("hit_root")


var get_start_position: Callable
var get_direction: Callable

#var attack_instance : Node # points to the Attack Node
var attack_properties : SpellCardData # stores the Attack and Hit properties
#var on_spawn_hit_attacks : Array[EntityAttack] # Attacks to be called when firing a Hit
#var on_hit_attacks : Array[EntityAttack] # Attacks to be called on hit

static var EMPTY_ENTITY_ATTACK = EntityAttack.new()

func setup_attack(spellcard_data : SpellCardData, get_start_position_arg, get_direction_arg):
	var attack_obj_path = SpellCardData.get_hit_type(spellcard_data.hit_type)
	hit_object = load(attack_obj_path)
#	attack_instance = attack_obj
	attack_properties = spellcard_data
	
	self.get_start_position = get_start_position_arg
	self.get_direction = get_direction_arg
	pass
#
#func setup_modifier(_spellcard_data : SpellCardData):
#	pass

## Call outside to spawn the hits
func do_attack():
	_spawn_hits(attack_properties)

func spawn_bullet(target_vector):
	var hit_instance = hit_object.instantiate()
	
	# TODO replace these player references
	# set hit instance properties
	hit_instance.position = get_start_position.call()
	hit_instance.target = target_vector
	
	# Set Hit combat properties
	_load_properties_into_hit(hit_instance)

	# add the hit instance as a child, put into world
	hit_root.call_deferred("add_child", hit_instance)
#	hit_root.add_child()

func _load_properties_into_hit(hit_instance):
#	hit_instance.energy_drain = attack_properties.energy_drain
	hit_instance.damage = attack_properties.damage
#	hit_instance.action_delay = attack_properties.action_delay
#	hit_instance.num_attacks = attack_properties.num_attacks
#	hit_instance.spread = attack_properties.spread
	hit_instance.speed = attack_properties.velocity
	hit_instance.lifetime = attack_properties.lifetime
#	hit_instance.radius = attack_properties.radius
	hit_instance.knockback_amount = attack_properties.knockback
	hit_instance.attack_hp = attack_properties.hit_hp
	hit_instance.attack_size = attack_properties.hit_size
#	hit_instance.pierce = attack_properties.pierce
#	hit_instance.bounce = attack_properties.bounce

	for spellcard in attack_properties.on_hit_effect:
		hit_instance.on_hit_spellcards.append(spellcard)

#	hit_instance.hit_behaviour_type = attack_properties.hit_behaviour_type
	return hit_instance


func _spawn_hits(spellcard):
	if spellcard.hit_spawn_type == SpellCardData.HIT_SPAWN_TYPE.SPREAD and spellcard.num_attacks > 1:
		var attack_angle = spellcard.attack_angle
		var direction_shifted = deg_to_rad(attack_angle) / (spellcard.num_attacks-1)
		var left_direction = get_direction.call().rotated(deg_to_rad(-attack_angle/2))
		var right_direction = get_direction.call().rotated(deg_to_rad(attack_angle/2))

		for i in range(spellcard.num_attacks):
			if i % 2 == 0:
				spawn_bullet(get_start_position.call() + left_direction)
				left_direction = left_direction.rotated(direction_shifted)
			else:
				spawn_bullet(get_start_position.call() + right_direction)
				right_direction = right_direction.rotated(-direction_shifted)
	else:
		spawn_bullet(_get_hit_spawn_type(spellcard))

func _get_hit_spawn_type(spellcard):
	if spellcard.hit_spawn_type == SpellCardData.HIT_SPAWN_TYPE.RANDOM_TARGET:
		return player.get_random_target()
	elif spellcard.hit_spawn_type == SpellCardData.HIT_SPAWN_TYPE.PLAYER_DIRECTION:
		return get_start_position.call() + get_direction.call()










