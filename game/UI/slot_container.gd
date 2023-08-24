extends GridContainer

class_name SlotContainer

@export var inventory_data : InventoryData
@export var ItemSlot : PackedScene

var slots : int

func display_modifier_slots(cols = inventory_data.cols, rows = inventory_data.rows):
	# There are dynamic grid containers like the equipment's spellcard slots.
	# They start off as zero (0), and will be re-called when updated.
	if cols < 1:
		return

	columns = cols
	slots = cols * rows
	for index in range(slots):
		var item_slot = ItemSlot.instantiate()
		item_slot.inventory_data = inventory_data
		add_child(item_slot)
		if index < inventory_data.items.size():
			item_slot.display_item(inventory_data.items[index])
		
	
	# If items change, refresh the GridContainer
	# Call only once, we might call this method multiple times
	if not inventory_data.items_changed.is_connected(_on_Inventory_items_changed):
		inventory_data.items_changed.connect(_on_Inventory_items_changed)

func _on_Inventory_items_changed(indexes):
	for index in indexes:
		if index < slots:
			var item_slot = get_child(index)
			item_slot.display_item(inventory_data.items[index])

## TODO make this more performant?
func clear_children():
	for child in self.get_children():
		remove_child(child)
		child.queue_free()
	if inventory_data.items_changed.is_connected(_on_Inventory_items_changed):
		inventory_data.items_changed.disconnect(_on_Inventory_items_changed)

