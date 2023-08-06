extends GridContainer

class_name SlotContainer

@export var ModifierSlot : PackedScene # ??

var slots

func display_modifier_slots(cols, rows = 1):
	columns = cols
	slots = cols * rows
	for index in range(slots):
		var modifier_slot = ModifierSlot.instantiate()
		add_child(modifier_slot)
		modifier_slot.display_modifier(Inventory.modifiers[index])
	Inventory.modifiers_changed.connect(_on_Inventory_modifiers_changed)

func _on_Inventory_modifiers_changed(indexes):
	for index in indexes:
		if index < slots:
			var modifier_slot = get_child(index)
			modifier_slot.display_modifier(Inventory.modifiers[index])


