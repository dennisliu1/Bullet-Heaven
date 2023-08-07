extends Node2D

@onready var tooltip = $UI/Tooltip
@onready var drag_preview = $UI/DragPreview

func _ready():
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		var index = item_slot.get_index()
#		item_slot.connect("gui_input", self, "_on_ItemSlot_gui_input", [index])
		item_slot.mouse_entered.connect(show_tooltip.bind(item_slot.inventory_data, index))
		item_slot.mouse_exited.connect(hide_tooltip.bind())

func show_tooltip(inventory_data, index):
	var inventory_item = inventory_data.items[index]
	if inventory_item and !drag_preview.dragged_item:
		tooltip.display_info(inventory_item)
		tooltip.show()
	else:
		tooltip.hide()

func hide_tooltip():
	tooltip.hide()






