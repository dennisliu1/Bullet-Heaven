extends SlotContainer

@export var cols = Inventory.cols
@export var rows = Inventory.rows

func _ready():
	display_modifier_slots(cols, rows)
	await get_tree().process_frame
	position = (get_viewport_rect().size - get_rect().size) / 2
	hide()


