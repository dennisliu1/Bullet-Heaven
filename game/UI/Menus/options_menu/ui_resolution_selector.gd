extends Control

signal resolution_changed(new_resolution)
@onready var option_button: OptionButton = $OptionButton

func _on_option_button_item_selected(index):
	_update_selected_item(option_button.text)

func _update_selected_item(text: String):
	var values = text.split_floats("x")
	emit_signal("resolution_changed", Vector2(values[0], values[1]))

func set_resolution(resolution: Vector2):
	var resolution_text = "%sx%s" % [resolution.x, resolution.y]
	
	## This is O(n), but since there's so few items, I think it's okay.
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == resolution_text:
			option_button.select(i)
