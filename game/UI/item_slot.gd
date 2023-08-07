extends ColorRect

var inventory_data : InventoryData

var inventory_index : int = -1

@onready var item_icon = $Sprite2D
@onready var label_quantity = $LabelQuantity

func display_item(item: ItemData):
	if item:
		item_icon.texture = item.texture
		label_quantity.text = "" # str(item.quantity) if item.stackable else ""
	else:
		item_icon.texture = null
		label_quantity.text = ""

