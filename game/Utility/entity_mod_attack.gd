extends EntityAttack

@export var entity_attacks : Array[EntityAttack]

func do_attack():
	for i in range(entity_attacks.size()):
		entity_attacks[i].do_attack()
