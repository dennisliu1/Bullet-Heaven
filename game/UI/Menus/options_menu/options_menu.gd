extends Control


@onready var tab_container: TabContainer = $TabContainer
@onready var video_menu:Control = $TabContainer/Video

func _on_back_button_pressed():
	visible = false


func _on_apply_button_pressed():
	var settings = tab_container.get_current_tab_control().get_settings()
	PersistentData.save_settings(settings)
	PersistentData.update_settings(settings)

func set_settings(settings):
	video_menu.set_settings(settings)
