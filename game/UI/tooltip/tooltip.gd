extends ColorRect

@onready var margin_container = $MarginContainer
@onready var item_name = $MarginContainer/ItemName

func _process(_delta):
	position = get_global_mouse_position() + Vector2.ONE * 4

func display_info(item):
	item_name.text = item.name
	await get_tree().process_frame
	set_size(margin_container.get_size()) # ??


