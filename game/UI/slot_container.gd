extends GridContainer

class_name SlotContainer

@export var inventory_data : InventoryData
@export var ItemSlot : PackedScene

var slots : int

func display_modifier_slots(cols = inventory_data.cols, rows = inventory_data.rows):
	columns = cols
	slots = cols * rows
	for index in range(slots):
		var item_slot = ItemSlot.instantiate()
		item_slot.inventory_data = inventory_data
		add_child(item_slot)
		item_slot.display_item(inventory_data.items[index])
	
	# If items change, refresh the GridContainer
	inventory_data.items_changed.connect(_on_Inventory_items_changed)

func _on_Inventory_items_changed(indexes):
	for index in indexes:
		if index < slots:
			var item_slot = get_child(index)
			item_slot.display_item(inventory_data.items[index])
