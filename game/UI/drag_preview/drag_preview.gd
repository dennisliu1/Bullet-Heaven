extends Control
class_name DragPreview

var dragged_item = ItemData.EMPTY_ITEM_DATA : set = set_dragged_item

@export var inventory_menu_array : Array[SlotContainer]
@export var inventory_array : Array[InventoryData]
@export var tooltip : ColorRect

@onready var item_icon = $ItemIcon
@onready var item_quantity = $ItemQuantity

@onready var equipment_containers : Array[Node] = get_tree().get_nodes_in_group("equipment_container")

func _ready():
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		var index = item_slot.get_index()
		if item_slot.inventory_index >= 0:
			index = item_slot.inventory_index
		item_slot.gui_input.connect(_on_ItemSlot_gui_input.bind(item_slot.inventory_data, index))

func _process(_delta):
	if dragged_item:
		# Add a small shift so the DragPreview doesn't block mouse clicks.
		position = get_global_mouse_position() + Vector2(5,5)

func set_dragged_item(item):
	dragged_item = item
	if dragged_item:
		item_icon.texture = item.texture
		item_quantity.text = "" # str(dragged_item.quantity) if dragged_item.stackable else ""
	else:
		item_icon.texture = null
		item_quantity.text = ""

#func _unhandled_input(event):
#	if event.is_action_pressed("show_inventory_menu"):
#		# if the player is dragging an item around, don't close the inventory
#		if inventory_visible and dragged_item != ItemData.EMPTY_ITEM_DATA:
#			return
#
#		for i in range(inventory_menu_array.size()):
#			inventory_menu_array[i].visible = !inventory_menu_array[i].visible
#		for i in range(equipment_containers.size()):
#			equipment_containers[i].visible = !equipment_containers[i].visible
#		inventory_visible = !inventory_visible
#
##		get_parent().paused = !get_parent().paused
##		hide_tooltip()

func _on_ItemSlot_gui_input(event, inventory_data, index):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			drag_item(inventory_data, index)
#				hide_tooltip()

func drag_item(inventory_data, index):
	var inventory_item = inventory_data.items[index]
	
	if inventory_item != ItemData.EMPTY_ITEM_DATA and dragged_item == ItemData.EMPTY_ITEM_DATA: # pick item
		dragged_item = inventory_data.remove_item(index)
	elif inventory_item == ItemData.EMPTY_ITEM_DATA and dragged_item: # drop item
		dragged_item = inventory_data.set_item(index, dragged_item)
	elif inventory_item and dragged_item: # swap items
		dragged_item = inventory_data.set_item(index, dragged_item)

func hide_tooltip():
	tooltip.hide()

func bind_item_slot(item_slot, index = item_slot.get_index()):
	item_slot.gui_input.connect(_on_ItemSlot_gui_input.bind(item_slot.inventory_data, index))
