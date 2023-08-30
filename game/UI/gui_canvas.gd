extends CanvasLayer

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("player")

# GUI
var on_another_menu = false
var opened_menu = null
## timer
var time = 0
@onready var label_time = $LabelTime
## gems label
@onready var gems_container = $GemsContainer
@onready var gems_label_gems = $GemsContainer/LabelGems
## experience
@onready var exp_bar = $Control/ExperienceBar
@onready var label_level = $Control/ExperienceBar/LabelLevel
@onready var health_bar = $HealthBar
## level panel
var available_upgrade_options = [] # what is on offer
@onready var item_options = preload("res://UI/GUI/ItemOption/item_option.tscn")
@onready var level_panel = $LevelPanel
@onready var level_result = $LevelPanel/LabelLevelUp
@onready var level_up_options: VBoxContainer  = $LevelPanel/LevelUpOptions
## Death Menu
@onready var death_panel = $PanelDeath
@onready var label_result = $PanelDeath/LabelResult
@onready var audio_victory = $PanelDeath/AudioVictory
@onready var audio_defeat = $PanelDeath/AudioDefeat
@onready var death_button_menu = $PanelDeath/ButtonMenu
## Pause Menu
@onready var pause_panel = $PanelPause
@onready var pause_button_back_to_game = $PanelPause/ButtonReturnToGame
@onready var pause_button_menu = $PanelPause/ButtonMenu
## Shop menu
@onready var transition_shop_menu = $TransitionShopMenu
## inventory menu
@onready var inventory_menu = $InventoryPanel

func _ready():
	set_expbar(player.current_experience, calculate_experience_cap())
	set_health_bar(100, 100) # set the health bar to 100%, full bar

func _unhandled_input(event):
	
	if event.is_action_pressed("show_pause_menu") and not on_another_menu:
		_show_pause_panel()
	elif event.is_action_pressed("show_pause_menu") and on_another_menu and opened_menu == "pause_panel":
		if pause_panel.visible:
			_reset_pause_panel()
	if event.is_action_pressed("show_inventory_menu") and not on_another_menu:
		show_inventory_menu()
	elif event.is_action_pressed("show_inventory_menu") and on_another_menu and opened_menu == "inventory_menu":
		if inventory_menu.visible:
			hide_inventory_menu()


# --- health bar ---

func set_health_bar(hp, maxhp):
	health_bar.max_value = maxhp
	health_bar.value = hp

# --- getting experience ---

func get_experience(experience):
	calculate_experience(experience)

func calculate_experience(gem_exp):
	var exp_required = calculate_experience_cap()
	player.collected_experience += gem_exp
	if player.current_experience + player.collected_experience >= exp_required: # level up
		player.collected_experience -= exp_required - player.current_experience
		player.experience_level += 1
#		label_level.text = str("Level:", experience_level)
		player.current_experience = 0
		exp_required = calculate_experience_cap()
		level_up()
#		calculate_experience(0) # multi-levelup; TODO remove the recursion
	else:
		player.current_experience += player.collected_experience
		player.collected_experience = 0
	set_expbar(player.current_experience, exp_required)

func set_expbar(set_value = 1, set_max_value = 100):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value

## TODO move this into a json file to set
func calculate_experience_cap():
	var exp_cap = player.experience_level
	if player.experience_level < 20:
		exp_cap = player.experience_level * 5
	elif player.experience_level < 40:
		exp_cap = 95 * (player.experience_level-19) * 8
	else:
		exp_cap = 255 + (player.experience_level-39) * 12
	return exp_cap

func level_up():
	label_level.text = str("Level:", player.experience_level)
	_show_level_up_panel()
	pause_player()

## TODO Fully random spells for now, do tiered options in the future
func get_random_item():
	var random_item = Global.get_spellcards_data().values().pick_random()
	available_upgrade_options.append(random_item)
	return random_item

## item_option connection: When user clicks on the option, it calls this method.
func upgrade_character(upgrade):
	## Add selected spell to spell inventory
	player.inventory_data.add_item(upgrade)
	_reset_level_up_panel()
	unpause_player()
	calculate_experience(0)

## move panel into focus
func _show_level_up_panel():
	var tween = level_panel.create_tween()
	tween.tween_property(level_panel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	level_panel.visible = true
	
	# add level up options
	var options = 0
	var options_max = 3
	while options < options_max:
		var option_choice = item_options.instantiate()
		option_choice.item = get_random_item()
		level_up_options.add_child(option_choice)
		options += 1
	on_another_menu = true
	opened_menu = "level_up_panel"

## Reset Level Up Panel position
func _reset_level_up_panel():
	level_panel.visible = false
	level_panel.position = Vector2(800, 20)
	
	## Remove the upgrade options
	var option_children = level_up_options.get_children()
	for i in option_children:
		i.queue_free()
	
	## clear the upgrade options array
	available_upgrade_options.clear()
	on_another_menu = false
	opened_menu = null

## called by enemy_spawner to update the time
func change_time(argtime = 0):
	time = argtime
	var get_minutes = int(time/60.0)
	var get_seconds = time % 60
	if get_minutes < 10:
		get_minutes = str(0, get_minutes)
	if get_seconds < 10:
		get_seconds = str(0, get_seconds)
	label_time.text = str(get_minutes, ":", get_seconds)







# --- pause menu ---

func _on_button_return_to_game_click_end():
	_reset_pause_panel()

func _on_button_menu_click_end():
	unpause_player()
	var _level = get_tree().change_scene_to_file("res://UI/Menus/title_screen.tscn")

## move panel into focus
func _show_pause_panel():
	var tween = pause_panel.create_tween()
	tween.tween_property(pause_panel, "position", Vector2(220, 50), 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	pause_panel.visible = true
	on_another_menu = true
	opened_menu = "pause_panel"
	pause_player()

## Reset Pause Panel position
func _reset_pause_panel():
	pause_panel.visible = false
	pause_panel.position = Vector2(800, 20)
	on_another_menu = false
	opened_menu = null
	unpause_player()

# --- transition shop menu ---

func show_shop_menu():
	transition_shop_menu.visible = true
	on_another_menu = true
	opened_menu = "shop_menu"
	pause_player()

func hide_shop_menu():
	transition_shop_menu.visible = false
	on_another_menu = false
	opened_menu = null
	unpause_player()

func _on_transition_shop_menu_next_button_click():
	hide_shop_menu()

# --- pause ---

func pause_player():
	get_tree().paused = true
#	player.effects_container.pause_attacks()

func unpause_player():
	get_tree().paused = false
#	player.effects_container.unpause_attacks()

# --- inventory menu ---

func show_inventory_menu():
	inventory_menu.visible = true
	on_another_menu = true
	opened_menu = "inventory_menu"
	pause_player()

func hide_inventory_menu():
	inventory_menu.visible = false
	on_another_menu = false
	opened_menu = null
	unpause_player()
	inventory_menu.refresh_spell_effects_data()
	player.reset_attacks()

