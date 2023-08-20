extends SlotContainer

func _ready():
	display_modifier_slots()

	await get_tree().process_frame # wait for next frame
	# Position the inventory
#	position = (get_viewport_rect().size - get_rect().size) / 2


