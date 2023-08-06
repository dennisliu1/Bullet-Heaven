extends ColorRect

@onready var modifier_icon = $Sprite2D
@onready var label_quantity = $LabelQuantity

func display_modifier(modifier):
	if modifier:
		modifier_icon.texture = load(Global.ICON_PATH % modifier.icon)
		label_quantity.text = "" # str(modifier.quantity) if modifier.stackable else ""
	else:
		modifier_icon.texture = null
		label_quantity.text = ""

