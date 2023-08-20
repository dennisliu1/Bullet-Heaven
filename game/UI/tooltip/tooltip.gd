extends ColorRect
class_name Tooltip

@onready var margin_container = $MarginContainer
@onready var item_name = $MarginContainer/VBoxContainer/ItemName
@onready var item_description = $MarginContainer/VBoxContainer/ItemDescription

func _ready():
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		item_slot.mouse_entered.connect(show_tooltip.bind(item_slot.inventory_data, item_slot.get_index()))
		item_slot.mouse_exited.connect(hide_tooltip.bind())
	pass

func _process(_delta):
	position = get_global_mouse_position() + Vector2.ONE * 4

func display_info(item: ItemData):
	if item is EquipmentData:
		item_name.text = "%s" % [item.name]
		item_description.text = item.description
	elif item is SpellCardData:
		item_name.text = item.name
		item_description.text = item.description
	else:
		item_name.text = item.name
		item_description.text = ""
		
	await get_tree().process_frame
	# Set the background to be the same size as the itemName text
	set_size(margin_container.get_size())

func show_tooltip(inventory_data, index):
	if index >= inventory_data.items.size():
		return

	var inventory_item = inventory_data.items[index]
	if inventory_item == ItemData.EMPTY_ITEM_DATA:
		return
	
	if inventory_item:
#	if inventory_item and drag_preview.dragged_item == ItemData.EMPTY_ITEM_DATA:
		display_info(inventory_item)
		show()
	else:
		hide()

func hide_tooltip():
	hide()

func bind_item_slot(item_slot, index = item_slot.get_index()):
	item_slot.mouse_entered.connect(show_tooltip.bind(item_slot.inventory_data, index))
	item_slot.mouse_exited.connect(hide_tooltip.bind())
