## Attack is an Hit spawner, creating damaging objects to hurt enemies.
## Used inside an Action, which calls Attacks to spawn Hits.
extends Node
class_name EntityAttack

var attack_instance : Node # points to the Attack Node
var attack_properties : SpellCardData # stores the Attack and Hit properties
var on_spawn_hit_attacks : Array[EntityAttack] # Attacks to be called when firing a Hit
var on_hit_attacks : Array[EntityAttack] # Attacks to be called on hit

static var EMPTY_ENTITY_ATTACK = EntityAttack.new()

func setup_attack(spellcard_data : SpellCardData, attack_obj : Node):
	attack_instance = attack_obj
	attack_properties = spellcard_data.duplicate()
	pass

func setup_modifier(spellcard_data : SpellCardData):
	
	pass

















