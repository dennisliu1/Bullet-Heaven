extends Control

func _on_back_button_click_end():
	var title_screen = "res://UI/Menus/title_screen.tscn"
	var _level = get_tree().change_scene_to_file(title_screen)

func _on_next_button_click_end():
	var character_select_screen = "res://UI/Menus/character_select_menu.tscn"
	var _level = get_tree().change_scene_to_file(character_select_screen)
