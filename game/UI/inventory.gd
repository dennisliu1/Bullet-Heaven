extends Node

signal modifiers_changed(indexes)
signal equipped_changed(indexes)

var cols = 9
var rows = 1
var slots = cols * rows
var modifiers = []

var equip_slots = 9
var equipped = []
var equipment_slots = []

# OLD CODE, DELETE ME
func _ready():
	for i in range(slots):
		modifiers.append({})
	
	modifiers[0] = Global.get_modifier_by_key("lance")
	modifiers[1] = Global.get_modifier_by_key("divide_2")
	modifiers[2] = Global.get_modifier_by_key("burst_3")
	modifiers[3] = Global.get_modifier_by_key("heavy_shot")
	modifiers[4] = Global.get_modifier_by_key("homing")

func set_modifier(index, modifier):
	var previous_modifier = modifiers[index]
	modifiers[index] = modifier
	emit_signal("modifiers_changed", [index])
	return previous_modifier

func remove_modifier(index):
	var previous_modifier = modifiers[index].duplicate()
	modifiers[index].clear()
	emit_signal("modifiers_changed", [index])
	return previous_modifier

func set_modifier_quantity(index, amount):
	modifiers[index].quantity += amount
	if modifiers[index].quantity < 0:
		remove_modifier(index)
	else:
		emit_signal("modifiers_changed", [index])


