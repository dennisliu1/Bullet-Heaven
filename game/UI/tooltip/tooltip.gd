extends ColorRect
class_name Tooltip

@export var drag_preview : Control
@onready var margin_container = $MarginContainer
@onready var item_name = $MarginContainer/ItemName

func _ready():
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
#		var index = item_slot.get_index()
#		if item_slot.inventory_index >= 0:
#			index = item_slot.inventory_index
#		item_slot.connect("gui_input", self, "_on_ItemSlot_gui_input", [index])
		item_slot.mouse_entered.connect(show_tooltip.bind(item_slot.inventory_data, item_slot.get_index()))
		item_slot.mouse_exited.connect(hide_tooltip.bind())
	pass

func _process(_delta):
	position = get_global_mouse_position() + Vector2.ONE * 4

func display_info(item):
	if item is EquipmentData:
		item_name.text = "%s - %s" % [item.name, item.spell_slots]
	else:
		item_name.text = item.name
	await get_tree().process_frame
	# Set the background to be the same size as the itemName text
	set_size(margin_container.get_size())

func show_tooltip(inventory_data, index):
	if index >= inventory_data.items.size():
		return

	var inventory_item = inventory_data.items[index]
	if inventory_item and drag_preview.dragged_item == ItemData.EMPTY_ITEM_DATA:
		display_info(inventory_item)
		show()
	else:
		hide()

func hide_tooltip():
	hide()

func bind_item_slot(item_slot, index = item_slot.get_index()):
	item_slot.mouse_entered.connect(show_tooltip.bind(item_slot.inventory_data, index))
	item_slot.mouse_exited.connect(hide_tooltip.bind())