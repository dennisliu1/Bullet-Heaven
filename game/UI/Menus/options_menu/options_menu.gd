extends Control


@onready var tab_container: TabContainer = $TabContainer

func _on_back_button_pressed():
	visible = false


func _on_apply_button_pressed():
	var settings = tab_container.get_current_tab_control().get_settings()
	update_settings(settings)

func update_settings(settings: Dictionary):
	get_window().size = settings.resolution
	DisplayServer.window_set_vsync_mode(settings.vsync)
	if settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass
