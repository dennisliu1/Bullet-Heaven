extends Control

func _on_back_button_click_end():
	var stage_select_menu = "res://UI/Menus/stage_select_menu.tscn"
	var _level = get_tree().change_scene_to_file(stage_select_menu)


func _on_next_button_click_end():
	var character_equipment_screen = "res://UI/Menus/character_equipment_menu.tscn"
	var _level = get_tree().change_scene_to_file(character_equipment_screen)
