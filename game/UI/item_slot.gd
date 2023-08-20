extends ColorRect

var inventory_data : InventoryData

var inventory_index : int = -1 # TODO seems unused?

## Used for selection screens
var is_selected = false
var initial_color: Color = Color("333333")
var selected_color: Color = Color("a6a6a6")

@onready var item_icon = $Sprite2D
@onready var label_quantity = $LabelQuantity

func _ready():
	set_color(initial_color)

func display_item(item: ItemData):
	if item:
		item_icon.texture = item.texture
		label_quantity.text = "" # str(item.quantity) if item.stackable else ""
	else:
		item_icon.texture = null
		label_quantity.text = ""

# --- item_slot selection, used in selection screens

func toggle_selection():
	if is_selected:
		return unselect_item()
	else:
		return select_item()

func select_item():
	set_color(selected_color)
	is_selected = true
	return true

func unselect_item():
	set_color(initial_color)
	is_selected = false
	return false
