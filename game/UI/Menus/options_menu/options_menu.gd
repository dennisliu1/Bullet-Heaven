extends Control


@onready var tab_container: TabContainer = $TabContainer

func _on_back_button_pressed():
	pass # Replace with function body.


func _on_apply_button_pressed():
	var settings = tab_container.get_current_tab_control().get_settings()
	update_settings(settings)

func update_settings(settings):
	pass
