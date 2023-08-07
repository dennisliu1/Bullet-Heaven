extends Node2D

@export var equipment_data: EquipmentData

func set_equipped_item(equipped_data):
	equipment_data = equipped_data
	var spell_slots = equipment_data.spell_slots
	for i in range(spell_slots.size()):
		if spell_slots[i] != ItemData.EMPTY_ITEM_DATA:
			add_action(spell_slots[i])

func remove_equipped_item():
	equipment_data = null


func add_action(spellcard):
	if spellcard.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
		var attack_instance = load(SpellCardData.get_attack_type(spellcard.attack_type))
		add_child(attack_instance)






