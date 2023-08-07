extends Node

class_name InventoryData

signal items_changed(indexes)
signal equipped_changed(indexes)

@export var cols : int
@export var rows : int
@export var prefilled_equipment : Array[Array]

var slots = cols * rows
var items = []

func _ready():
	slots = cols * rows
	for i in range(slots):
		items.append(ItemData.EMPTY_ITEM_DATA)

	for i in range(min(prefilled_equipment.size(), items.size())):
		items[i] = Global.get_object_by_key(prefilled_equipment[i][0], prefilled_equipment[i][1])

func set_item(index, modifier):
	var previous_modifier = items[index]
	items[index] = modifier
	emit_signal("items_changed", [index])
	return previous_modifier

func remove_item(index):
	var previous_modifier = items[index]
	items[index] = ItemData.EMPTY_ITEM_DATA
	emit_signal("items_changed", [index])
	return previous_modifier

func set_item_quantity(index, amount):
	items[index].quantity += amount
	if items[index].quantity < 0:
		remove_item(index)
	else:
		emit_signal("items_changed", [index])

func set_bulk(insert_items, num_items):
	items.clear()
	cols = num_items
	slots = cols * rows
	var final_range = range(min(insert_items.size(), num_items))
	for i in range(min(insert_items.size(), slots)):
		items.append(insert_items[i])
	for i in range(insert_items.size(), slots):
		items.append(ItemData.EMPTY_ITEM_DATA)
	emit_signal("items_changed", final_range)

