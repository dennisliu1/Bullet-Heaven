extends ColorRect

var inventory_data : InventoryData

@onready var item_icon = $Sprite2D
@onready var label_quantity = $LabelQuantity

func display_item(item):
	if item:
		item_icon.texture = load(item.path + item.icon)
		label_quantity.text = "" # str(item.quantity) if item.stackable else ""
	else:
		item_icon.texture = null
		label_quantity.text = ""

