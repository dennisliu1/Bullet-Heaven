extends Control

func _ready():
	pass

func _on_back_button_click_end():
	var character_select_menu = "res://UI/Menus/character_select_menu.tscn"
	var _level = get_tree().change_scene_to_file(character_select_menu)

func _on_next_button_click_end():
	var world_game = "res://World/world.tscn"
	var _level = get_tree().change_scene_to_file(world_game)
