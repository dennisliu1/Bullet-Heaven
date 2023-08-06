extends Node2D

@onready var inventory_menu = $UI/InventoryMenu
@onready var drag_preview = $UI/DragPreview

func _ready():
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		var index = item_slot.get_index()
		item_slot.gui_input.connect(_on_ItemSlot_gui_input.bind(index))
#		item_slot.connect("gui_input", self, "_on_ItemSlot_gui_input", [index])

func _unhandled_input(event):
	if event.is_action_pressed("show_inventory_menu"):
		# if the player is dragging an item around, don't close the inventory
		if inventory_menu.visible and drag_preview.dragged_item:
			return

		inventory_menu.visible = !inventory_menu.visible
#		get_tree().paused = !get_tree().paused

func _on_ItemSlot_gui_input(event, index):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if inventory_menu.visible:
				drag_item(index)

func drag_item(index):
	var inventory_item = Inventory.modifiers[index]
	var dragged_item = drag_preview.dragged_item
	
	if inventory_item != {} and dragged_item == {}: # pick item
		drag_preview.dragged_item = Inventory.remove_modifier(index)
	elif inventory_item == {} and dragged_item: # drop item
		drag_preview.dragged_item = Inventory.set_modifier(index, dragged_item)
	elif inventory_item and dragged_item: # swap items
		drag_preview.dragged_item = Inventory.set_modifier(index, dragged_item)
	
