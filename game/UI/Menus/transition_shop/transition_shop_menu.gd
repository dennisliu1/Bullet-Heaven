extends Control

signal next_button_click()

func _on_next_button_click_end():
	emit_signal("next_button_click")
