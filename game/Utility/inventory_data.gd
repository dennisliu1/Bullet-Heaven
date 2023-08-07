extends Node

class_name InventoryData

signal items_changed(indexes)
signal equipped_changed(indexes)

@export var cols = 9
@export var rows = 1
@export var prefilled_equipment : Array[Array]

var slots = cols * rows
var items = []

func _ready():
	for i in range(slots):
		items.append({})

	for i in range(min(prefilled_equipment.size(), items.size())):
		items[i] = Global.get_object_by_key(prefilled_equipment[i][0], prefilled_equipment[i][1])

func set_item(index, modifier):
	var previous_modifier = items[index]
	items[index] = modifier
	emit_signal("items_changed", [index])
	return previous_modifier

func remove_item(index):
	var previous_modifier = items[index].duplicate()
	items[index].clear()
	emit_signal("items_changed", [index])
	return previous_modifier

func set_item_quantity(index, amount):
	items[index].quantity += amount
	if items[index].quantity < 0:
		remove_item(index)
	else:
		emit_signal("items_changed", [index])
