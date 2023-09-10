extends Control

@onready var ui_resolution_selection = $VBoxContainer/UIResolutionSelector

var _settings = {resolution = Vector2(640, 360), fullscreen = false, vsync = false}


func get_settings():
	return _settings

func _on_ui_resolution_selector_resolution_changed(new_resolution):
	_settings.resolution = new_resolution


func _on_full_screen_checkbox_toggled(is_button_pressed):
	_settings.fullscreen = is_button_pressed

func _on_v_sync_checkbox_toggled(is_button_pressed):
	_settings.vsync = is_button_pressed
