extends Node

class_name InventoryData

enum INVENTORY_TYPE {GENERAL, EQUIPMENT_ONLY, SPELLS_ONLY}

signal items_changed(indexes)
signal items_set(items)
signal items_removed(items)
signal equipped_changed(indexes)

@export var cols : int
@export var rows : int
@export var prefilled_equipment : Array[Array]
@export var inventory_type: INVENTORY_TYPE = INVENTORY_TYPE.GENERAL

var slots = cols * rows
var items = []

func _ready():
	slots = cols * rows
	for i in range(slots):
		items.append(ItemData.EMPTY_ITEM_DATA)

	for i in range(min(prefilled_equipment.size(), items.size())):
		items[i] = Global.get_object_by_key(prefilled_equipment[i][0], prefilled_equipment[i][1])

func set_item(index, item):
	if not valid_item_type(item):
		return item
	
	var previous_item = items[index]
	items[index] = item
	emit_signal("items_changed", [index])
	emit_signal("items_set", [item])
	emit_signal("items_removed", [previous_item])
	return previous_item

func remove_item(index):
	var previous_item = items[index]
	items[index] = ItemData.EMPTY_ITEM_DATA
	emit_signal("items_changed", [index])
	emit_signal("items_removed", [previous_item])
	return previous_item

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

func valid_item_type(item):
	if inventory_type == INVENTORY_TYPE.GENERAL:
		return true
	elif inventory_type == INVENTORY_TYPE.EQUIPMENT_ONLY and item.type == ItemData.ITEM_TYPE.EQUIPMENT:
		return true
	elif inventory_type == INVENTORY_TYPE.SPELLS_ONLY and item.type == ItemData.ITEM_TYPE.SPELLCARD:
		return true
	return false

