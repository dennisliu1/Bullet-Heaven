## Attack is an Hit spawner, creating damaging objects to hurt enemies.
## Used inside an Action, which calls Attacks to spawn Hits.
extends Node
class_name EntityAttack

var hit_object
var on_fire_hit_objects: Array
var on_fire_effects: Array

var attack_enabled = true

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var hit_root = get_tree().get_first_node_in_group("hit_root")


var get_start_position: Callable
var get_direction: Callable
var attack_properties : SpellCardEffect # stores the Attack and Hit properties

static var EMPTY_ENTITY_ATTACK = EntityAttack.new()

func setup_attack(spellcard_data : SpellCardEffect, get_start_position_arg, get_direction_arg):
#	attack_instance = attack_obj
	attack_properties = spellcard_data

	var attack_obj_path = SpellCardEffect.get_hit_type(spellcard_data.hit_type)
	hit_object = load(attack_obj_path)
	for spell_effect in spellcard_data.on_fire_effects:
		attack_obj_path = SpellCardEffect.get_hit_type(spell_effect.hit_type)
		hit_object = load(attack_obj_path)
		
		on_fire_hit_objects.append(hit_object)
		on_fire_effects.append(spell_effect)
	
	
	self.get_start_position = get_start_position_arg
	self.get_direction = get_direction_arg
	pass

## Call outside to spawn the hits
func do_attack():
	for i in range(on_fire_hit_objects.size()):
		_spawn_hits(on_fire_effects[i], on_fire_hit_objects[i])
	_spawn_hits(attack_properties, hit_object)

func spawn_bullet(target_vector, hit_obj):
	var hit_instance = hit_obj.instantiate()
	
	# TODO replace these player references
	# set hit instance properties
	hit_instance.position = get_start_position.call()
	hit_instance.target = target_vector
	
	# Set Hit combat properties
	_load_properties_into_hit(hit_instance, attack_properties)

	# add the hit instance as a child, put into world
	hit_root.call_deferred("add_child", hit_instance)
#	hit_root.add_child()

func _load_properties_into_hit(hit_instance, spell_effect):
#	hit_instance.energy_drain = spell_effect.energy_drain
	hit_instance.damage = spell_effect.damage
#	hit_instance.action_delay = spell_effect.action_delay
#	hit_instance.num_attacks = spell_effect.num_attacks
#	hit_instance.spread = spell_effect.spread
	hit_instance.speed = spell_effect.velocity
	hit_instance.lifetime = spell_effect.lifetime
#	hit_instance.radius = spell_effect.radius
	hit_instance.knockback_amount = spell_effect.knockback
	hit_instance.attack_hp = spell_effect.hit_hp
	hit_instance.attack_size = spell_effect.hit_size
#	hit_instance.pierce = spell_effect.pierce
#	hit_instance.bounce = spell_effect.bounce

	for spellcard in attack_properties.on_hit_effects:
		hit_instance.on_hit_spellcards.append(spellcard)

	return hit_instance

func _spawn_hits(spellcard_effect, bullet_obj):
	if spellcard_effect.hit_spawn_type == SpellCardEffect.HIT_SPAWN_TYPE.SPREAD and spellcard_effect.num_attacks > 1:
		var attack_angle = spellcard_effect.attack_angle
		var direction_shifted = deg_to_rad(attack_angle) / (spellcard_effect.num_attacks-1)
		var left_direction = get_direction.call().rotated(deg_to_rad(-attack_angle/2))
		var right_direction = get_direction.call().rotated(deg_to_rad(attack_angle/2))

		for i in range(spellcard_effect.num_attacks):
			if i % 2 == 0:
				spawn_bullet(get_start_position.call() + left_direction, bullet_obj)
				left_direction = left_direction.rotated(direction_shifted)
			else:
				spawn_bullet(get_start_position.call() + right_direction, bullet_obj)
				right_direction = right_direction.rotated(-direction_shifted)
	else:
		spawn_bullet(_get_hit_spawn_type(spellcard_effect), bullet_obj)

func _get_hit_spawn_type(spellcard):
	if spellcard.hit_spawn_type == SpellCardEffect.HIT_SPAWN_TYPE.RANDOM_TARGET:
		return player.get_random_target()
	elif spellcard.hit_spawn_type == SpellCardEffect.HIT_SPAWN_TYPE.PLAYER_DIRECTION:
		return get_start_position.call() + get_direction.call()

## matches entity_hit







