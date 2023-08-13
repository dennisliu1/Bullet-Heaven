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


#var attack_instance : Node # points to the Attack Node
var attack_properties : SpellCardData # stores the Attack and Hit properties
#var on_spawn_hit_attacks : Array[EntityAttack] # Attacks to be called when firing a Hit
#var on_hit_attacks : Array[EntityAttack] # Attacks to be called on hit

static var EMPTY_ENTITY_ATTACK = EntityAttack.new()

func setup_attack(spellcard_data : SpellCardData):
	var attack_obj_path = SpellCardData.get_hit_type(spellcard_data.hit_type)
	hit_object = load(attack_obj_path)
#	attack_instance = attack_obj
	attack_properties = spellcard_data.duplicate()
	pass
#
#func setup_modifier(_spellcard_data : SpellCardData):
#	pass

func spawn_bullet():
	var hit_instance = hit_object.instantiate()
	
	# TODO replace these player references
	# set hit instance properties
	hit_instance.position = player.position
#	hit_instance.enemy_detect_area = enemy_detect_area
	hit_instance.target = player.get_random_target()
	_load_properties_into_hit(hit_instance)

	# Set Hit combat properties

	# add the hit instance as a child, put into world
	add_child(hit_instance)

func do_attack():
	spawn_bullet()

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
	return hit_instance



















