extends Panel

var inventory_menu = self

@export var inventory_data : InventoryData

@onready var inventory_container = $InventoryContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	for item_slot in inventory_container.get_children():
		var index = item_slot.get_index()
		item_slot.gui_input.connect(_on_ItemSlot_gui_input.bind(item_slot, index))

func _on_ItemSlot_gui_input(event, item_slot, index):
	pass
