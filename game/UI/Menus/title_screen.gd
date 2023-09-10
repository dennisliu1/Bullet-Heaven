extends Control

#var level = "res://World/world.tscn"
@onready var options_menu = $OptionsMenu

func _ready():
	var settings = PersistentData.load_settings()
	PersistentData.update_settings(settings)
	options_menu.set_settings(settings)

func _on_button_play_click_end():
	var level = "res://UI/Menus/stage_select_menu.tscn"
	var _level = get_tree().change_scene_to_file(level)


func _on_button_exit_click_end():
	get_tree().quit()

func _on_options_button_click_end():
	options_menu.visible = true

