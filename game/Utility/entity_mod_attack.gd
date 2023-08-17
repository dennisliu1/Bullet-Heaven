extends EntityAttack

@export var entity_attacks : Array[EntityAttack]

func setup_attack(spellcard_data : SpellCardEffect, get_start_position_arg, get_direction_arg):
#	attack_instance = attack_obj
	attack_properties = spellcard_data
	
	self.get_start_position = get_start_position_arg
	self.get_direction = get_direction_arg
	pass

func do_attack():
	for i in range(entity_attacks.size()):
		var mod_effect = entity_attacks[i].attack_properties
		var mod_hit_object = entity_attacks[i].hit_object
		_spawn_hits(attack_properties, mod_effect, mod_hit_object)
