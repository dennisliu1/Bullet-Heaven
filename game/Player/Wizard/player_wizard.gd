extends CharacterBody2D

# player game variables
var movement_speed = 80.0 # 80 pixels per second moved
var armor = 0

# player base properties
var experience_level = 1
var maxhp = 80
@export var hp = 80

# tracking variables
var current_experience = 0
var collected_experience = 0
var last_movement = Vector2.UP
var collected_gems = 0

# references
@onready var sprite = $Sprite2D
@onready var walk_timer = $WalkTimer

# attacks

## ice spear
@onready var attack_container = $Attack

var ice_spear = preload("res://Player/Attacks/Ice Spear/ice_spear.tscn")

# GUI
## timer
var time = 0
@onready var label_time = $CanvasLayer/LabelTime
## gems label
@onready var gems_container = $CanvasLayer/GemsContainer
@onready var gems_label_gems = $CanvasLayer/GemsContainer/LabelGems
## experience
@onready var exp_bar = $CanvasLayer/Control/ExperienceBar
@onready var label_level = $CanvasLayer/Control/ExperienceBar/LabelLevel
@onready var health_bar = $CanvasLayer/HealthBar
## level panel
var available_upgrade_options = [] # what is on offer
@onready var item_options = preload("res://UI/GUI/ItemOption/item_option.tscn")
@onready var level_panel = $CanvasLayer/LevelPanel
@onready var level_result = $CanvasLayer/LevelPanel/LabelLevelUp
@onready var level_up_options: VBoxContainer  = $CanvasLayer/LevelPanel/LevelUpOptions
## Death Menu
@onready var death_panel = $CanvasLayer/PanelDeath
@onready var label_result = $CanvasLayer/PanelDeath/LabelResult
@onready var audio_victory = $CanvasLayer/PanelDeath/AudioVictory
@onready var audio_defeat = $CanvasLayer/PanelDeath/AudioDefeat
@onready var death_button_menu = $CanvasLayer/PanelDeath/ButtonMenu
## Pause Menu
@onready var pause_panel = $CanvasLayer/PanelPause
@onready var pause_button_back_to_game = $CanvasLayer/PanelPause/ButtonReturnToGame
@onready var pause_button_menu = $CanvasLayer/PanelPause/ButtonMenu
## Shop menu
@onready var transition_shop_menu = $CanvasLayer/TransitionShopMenu



# enemy related
var enemy_close = []

@onready var equipment_inventory : InventoryData = get_tree().get_first_node_in_group("equipment_inventory")
@onready var spellcard_inventory : InventoryData = get_tree().get_first_node_in_group("spellcard_inventory")

signal player_death()

func _ready():
	set_expbar(current_experience, calculate_experience_cap())
	# initialize health bar
	_on_hurt_box_hurt(0, 0, 0)
	
	set_process_unhandled_input(true)


func _unhandled_input(event):
	if event.is_action_pressed("show_pause_menu"):
		if pause_panel.visible:
			_reset_pause_panel()
		else:
			_show_pause_panel()
		
		

func _physics_process(_delta): # 60 FPS
	movement()

func movement():
	# get_action_strength return 0 or 1, if it is pressed = 1
	# so left = 1 - 0 = 1
	var x_move = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_move = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var move_direction = Vector2(x_move, y_move)

	if move_direction != Vector2.ZERO:
		last_movement = move_direction
		_animate_walk_frame()

	# change the sprite direction.
	_change_sprite_direction(move_direction)

	# normalize to get the vector direction, handles diagonal length properly
	# Multiply by delta to update based on current frame rate.
	# move_and_slide already multiplies by delta, so we don't need to use it in velocity.
	velocity = move_direction.normalized() * movement_speed
	move_and_slide()


## Manually animate the walk frames.
## Needs this because the player can pause at any time,
## where the player should pause the frame.
func _animate_walk_frame():
	if walk_timer.is_stopped():
		if sprite.frame >= sprite.hframes - 1: # reached the end frame, reset
			sprite.frame = 0
		else:
			sprite.frame += 1
#		$AnimationPlayer.play("walk")
		walk_timer.start()

## Change the direction the sprite faces, depending on the move direction.
func _change_sprite_direction(move_direction):
	if move_direction.x > 0:
		sprite.flip_h = true
	elif move_direction.x < 0:
		sprite.flip_h = false



func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	hp -= clamp(damage - armor, 1.0, 999)
	health_bar.max_value = maxhp
	health_bar.value = hp
	if hp <= 0:
		death()

func death():
	death_panel.visible = true
	emit_signal("player_death")
	get_tree().paused = true
	
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

func _on_button_menu_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://UI/Menus/title_screen.tscn")

# ---

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP # TODO shoot at the last target vector

func _on_enemy_detect_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detect_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func set_equipped_item(equipment_data, index):
	if equipment_data is EquipmentData:
		var equipped_item = attack_container.get_child(index)
		return equipped_item.set_equipped_item(equipment_data)
	else:
		return remove_equipped_item(index)

func remove_equipped_item(index):
	var equipped_item = attack_container.get_child(index)
	return equipped_item.remove_equipped_item()

# deprecated, not used
func add_attack(attack_instance, index):
	var equipped_item = attack_container.get_child(index)
	equipped_item.add_child(attack_instance)

func add_attack_by_spellcard_effect(spellcard_effect, index):
	var equipped_item = attack_container.get_child(index)
	return equipped_item.add_spellcard_effect(spellcard_effect)

func remove_spellcard_effect(spellcard_effect, index):
	var equipped_item = attack_container.get_child(index)
	return equipped_item.remove_spellcard_effect(spellcard_effect)

func sync_bulk_spellcard_effects(instance_stack, index):
	var equipped_item = attack_container.get_child(index)
	return equipped_item.sync_bulk_spellcard_effects(instance_stack)

# --- getting gems ---

## The Grab Area is the area where items are attracted to the player.
func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

## The Collect Area is the area on the player which picks up the item.
func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		collected_gems += area.value
		gems_label_gems.text = str(collected_gems)


# --- getting experience ---

func get_experience(experience):
	calculate_experience(experience)

func calculate_experience(gem_exp):
	var exp_required = calculate_experience_cap()
	collected_experience += gem_exp
	if current_experience + collected_experience >= exp_required: # level up
		collected_experience -= exp_required - current_experience
		experience_level += 1
#		label_level.text = str("Level:", experience_level)
		current_experience = 0
		exp_required = calculate_experience_cap()
		level_up()
#		calculate_experience(0) # multi-levelup; TODO remove the recursion
	else:
		current_experience += collected_experience
		collected_experience = 0
	set_expbar(current_experience, exp_required)

func set_expbar(set_value = 1, set_max_value = 100):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value

## TODO move this into a json file to set
func calculate_experience_cap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 * (experience_level-19) * 8
	else:
		exp_cap = 255 + (experience_level-39) * 12
	return exp_cap

func level_up():
	label_level.text = str("Level:", experience_level)
	_show_level_up_panel()
	get_tree().paused = true # pauses the game!

## TODO Fully random spells for now, do tiered options in the future
func get_random_item():
	var random_item = Global.get_spellcards_data().values().pick_random()
	available_upgrade_options.append(random_item)
	return random_item

## item_option connection: When user clicks on the option, it calls this method.
func upgrade_character(upgrade):
	## Add selected spell to spell inventory
	spellcard_inventory.add_item(upgrade)
	_reset_level_up_panel()
	get_tree().paused = false
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

# --- Pause Menu ---

func _on_button_return_to_game_click_end():
	_reset_pause_panel()

## move panel into focus
func _show_pause_panel():
	var tween = pause_panel.create_tween()
	tween.tween_property(pause_panel, "position", Vector2(220, 50), 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	pause_panel.visible = true
	get_tree().paused = true

## Reset Pause Panel position
func _reset_pause_panel():
	pause_panel.visible = false
	pause_panel.position = Vector2(800, 20)
	get_tree().paused = false

# --- transition shop menu ---

func show_shop_menu():
	transition_shop_menu.visible = true
	get_tree().paused = true

func hide_shop_menu():
	transition_shop_menu.visible = false
	get_tree().paused = false

func _on_transition_shop_menu_next_button_click():
	hide_shop_menu()
