extends EntityAttack

@export var entity_attacks : Array[EntityAttack]


func setup_attack(spellcard_data : SpellCardEffect, get_start_position_arg, get_direction_arg):
	attack_properties = spellcard_data
	hit_effect = attack_properties
	
	self.get_start_position_callable = get_start_position_arg
	self.get_direction_callable = get_direction_arg
	
	pass

func setup_effect():
	if not attack_properties.multicast and entity_attacks.size() > 0:
		# should be size one
		var mod_effect = entity_attacks[0].attack_properties
		var mod_hit_object = entity_attacks[0].hit_object
		if mod_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
			pass
		else:
			# combine attack_properties and mod_effects together
			var combined_effect = mod_effect.duplicate()
			SpellCardEffect.apply_modifier_to_spellcard(combined_effect, attack_properties)
			hit_effect = combined_effect # should combine attack_properties and mod_effect
			hit_object = mod_hit_object
			update_effects()

func do_attack():
	if attack_properties.multicast:
		_spawn_multicast_attacks(attack_properties, entity_attacks, true)
	else:
		var mod_effect = entity_attacks[0].attack_properties
		var mod_hit_object = entity_attacks[0].hit_object
		if mod_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
			_spawn_multicast_attacks(attack_properties, entity_attacks, false)
		else:
			# TODO move this out of attack, looping too much
			_spawn_hits(attack_properties, hit_effect, hit_object)
#			_spawn_hits(attack_properties, mod_effect, mod_hit_object)

func _spawn_multicast_attacks(spawn_effect, entity_attacks_arr, multicast):
	var j = 0
	var entity_attack = entity_attacks_arr[j]
	
	if spawn_effect.hit_spawn_type == SpellCardEffect.HIT_SPAWN_TYPE.SPREAD:
		var attack_angle = spawn_effect.attack_angle
		var effective_attacks = spawn_effect.num_attacks if (attack_angle == 360) else spawn_effect.num_attacks-1
		var direction_shifted = deg_to_rad(attack_angle) / effective_attacks
		var left_direction = get_direction().rotated(deg_to_rad(-attack_angle/2))
		var right_direction = get_direction().rotated(deg_to_rad(attack_angle/2))

		for i in range(spawn_effect.num_attacks):
			if attack_angle == 360:
				entity_attack.start_position = get_start_position()
				entity_attack.direction_vector = get_start_position() + left_direction
				entity_attack.start_single_attack_sequence()
				left_direction = left_direction.rotated(direction_shifted)
			else:
				if i % 2 == 0:
					entity_attack.start_position = get_start_position()
					entity_attack.direction_vector = get_start_position() + left_direction
					entity_attack.start_single_attack_sequence()
					left_direction = left_direction.rotated(direction_shifted)
				else:
					entity_attack.start_position = get_start_position()
					entity_attack.direction_vector = get_start_position() + right_direction
					entity_attack.start_single_attack_sequence()
					right_direction = right_direction.rotated(-direction_shifted)
			
			if multicast:
				j = (j + 1) % entity_attacks_arr.size()
				entity_attack = entity_attacks_arr[j]
		entity_attack.start_position = null
		entity_attack.direction_vector = null
	else:
		entity_attack.start_attack_sequence()
