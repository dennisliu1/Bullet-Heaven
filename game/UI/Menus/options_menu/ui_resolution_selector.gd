extends Control

signal resolution_changed(new_resolution)
@onready var option_button: OptionButton = $OptionButton

func _on_option_button_item_selected(index):
	_update_selected_item(option_button.text)

func _update_selected_item(text: String):
	var values = text.split_floats("x")
	emit_signal("resolution_changed", Vector2(values[0], values[1]))
