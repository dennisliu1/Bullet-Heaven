extends EntityAttack

@export var entity_attacks : Array[EntityAttack]

var get_start_position_default
var get_direction_default

func setup_attack(spellcard_data : SpellCardEffect, get_start_position_arg, get_direction_arg):
	attack_properties = spellcard_data
	
	get_start_position_default = get_start_position_arg
	get_direction_default = get_direction_arg
	self.get_start_position = get_start_position_default
	self.get_direction = get_direction_default
	pass

func do_attack():
	for i in range(entity_attacks.size()):
		var mod_effect = entity_attacks[i].attack_properties
		var mod_hit_object = entity_attacks[i].hit_object
		if mod_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
			_spawn_attacks(attack_properties, entity_attacks[i])
		else:
			_spawn_hits(attack_properties, mod_effect, mod_hit_object)

func _spawn_attacks(spawn_effect, entity_attack):
	if spawn_effect.hit_spawn_type == SpellCardEffect.HIT_SPAWN_TYPE.SPREAD and spawn_effect.num_attacks > 1:
		var attack_angle = spawn_effect.attack_angle
		var direction_shifted = deg_to_rad(attack_angle) / (spawn_effect.num_attacks-1)
		var left_direction = get_direction.call().rotated(deg_to_rad(-attack_angle/2))
		var right_direction = get_direction.call().rotated(deg_to_rad(attack_angle/2))

		for i in range(spawn_effect.num_attacks):
			if i % 2 == 0:
#				entity_attack.get_start_position = get_start_position
#				entity_attack.get_direction = get_start_position.call() + left_direction
				entity_attack.do_attack()
				left_direction = left_direction.rotated(direction_shifted)
			else:
#				entity_attack.get_start_position = get_start_position
#				entity_attack.get_direction = get_start_position.call() + right_direction
				entity_attack.do_attack()
				right_direction = right_direction.rotated(-direction_shifted)
	else:
		entity_attack.do_attack()
