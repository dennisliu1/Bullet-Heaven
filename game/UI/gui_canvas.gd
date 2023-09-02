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
@onready var shop_buy_item = preload("res://UI/Menus/transition_shop/shop_buy_item.tscn")
@onready var transition_shop_menu = $TransitionShopMenu
var shop_options = []


## inventory menu
@onready var inventory_menu = $InventoryPanel

func _ready():
	set_expbar(player.current_experience, player.calculate_experience_cap())
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

func set_expbar(set_value = 1, set_max_value = 100):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value

func level_up():
	label_level.text = str("Level:", player.experience_level)
	_show_level_up_panel()
	pause_player()

## TODO Fully random spells for now, do tiered options in the future
func get_random_item():
	var random_item = Global.get_spellcards_data().values().pick_random()
	available_upgrade_options.append(random_item)
	return random_item

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
	refresh_gem_label()
	
	# add shops options
	add_items()
	
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

func buy_item(index, item, price):
	if player.buy_item(item, price):
		shop_options[index].bought = true
		refresh_gem_label()
	pass

func lock_item(index, _item):
	shop_options[index].lock = true
	pass

func unlock_item(index, _item):
	shop_options[index].lock = false
	pass

func reroll():
	var i = 0
	while i < shop_options.size():
		if shop_options[i].lock:
			i += 1
		else:
			transition_shop_menu.remove_buy_option(shop_options[i].node)
			shop_options.remove_at(i)
	add_items()
	pass

func add_items(options_max = 8):
	var options = shop_options.size()
	while shop_options.size() < options_max:
		var shop_buy_item_option = shop_buy_item.instantiate()
		var item = get_random_item()
		shop_options.append({
			"item": item,
			"lock": false,
			"bought": false,
			"node": shop_buy_item_option,
		})
		transition_shop_menu.add_buy_option(shop_buy_item_option)
		shop_buy_item_option.set_item(options, item, item.price)
		shop_buy_item_option.connect_item(self, "buy_item", "lock_item", "unlock_item")
		
		options += 1

func _on_transition_shop_menu_reroll_items():
	reroll()

func refresh_gem_label():
	transition_shop_menu.get_gems_container_label().text = str(player.collected_gems)

# --- pause ---

func pause_player():
	get_tree().paused = true

func unpause_player():
	get_tree().paused = false

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

# --- death panel ---

func show_death_panel():
	death_panel.visible = true
	pause_player()
	
	## show death menu
	var tween = death_panel.create_tween()
	tween.tween_property(death_panel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
	## choose victory or defeat message
	if time >= 300:
		label_result.text = "You win!"
		audio_victory.play()
	else:
		label_result.text = "You lose :("
		audio_defeat.play()








