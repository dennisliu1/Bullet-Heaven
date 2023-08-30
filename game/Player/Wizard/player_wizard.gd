extends CharacterBody2D
class_name Player

# player game variables
var movement_speed = 80.0 # 80 pixels per second moved
var armor = 0

# player base properties
var experience_level = 1
var maxhp = 80
@export var hp = 80
@export var gui: CanvasLayer

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
@onready var effects_container = $EffectsContainer

var ice_spear = preload("res://Player/Attacks/Ice Spear/ice_spear.tscn")

### inventory menu
@onready var inventory_data = $InventoryData
@onready var spellcard_inventory = $SpellCardInventoryData
#@onready var inventory_menu = $CanvasLayer/InventoryPanel

# enemy related
var enemy_close = []

signal player_death()

func _ready():
	# testing data
	for item_data in Global.get_preview_items():
		var item = Global.get_object_by_key(item_data[0], item_data[1])
		inventory_data.add_item(item)
	
	# Add starting equipment
	for item in StartingGameData.get_starting_spells():
		spellcard_inventory.add_item(item)
	
	refresh_spell_effects_data()
	reset_attacks()

func refresh_spell_effects_data():
	var instance_stack = SpellCardEffect.evaluate_spellcards(spellcard_inventory.items as Array[SpellCardData])
	sync_bulk_spellcard_effects(instance_stack)

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
	gui.set_health_bar(hp, maxhp)
	if hp <= 0:
		death()

func death():
	emit_signal("player_death")
	gui.show_death_panel()


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

# --- sync spell card situation

func sync_bulk_spellcard_effects(instance_stack):
	effects_container.sync_bulk_spellcard_effects(instance_stack)

# --- getting gems ---

## The Grab Area is the area where items are attracted to the player.
func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

## The Collect Area is the area on the player which picks up the item.
func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var _gem_exp = area.collect()
		collected_gems += area.value
		gui.gems_label_gems.text = str(collected_gems)

func reset_attacks():
	effects_container.reset_attacks()

# --- getting experience ---

## item_option connection: When user clicks on the option, it calls this method.
func upgrade_character(upgrade):
	## Add selected spell to spell inventory
	inventory_data.add_item(upgrade)
	gui._reset_level_up_panel()
	gui.unpause_player()
	calculate_experience(0)

## Used by enemy to give exp to the player
func get_experience(experience):
	calculate_experience(experience)

func calculate_experience(gem_exp):
	var exp_required = calculate_experience_cap()
	collected_experience += gem_exp
	if current_experience + collected_experience >= exp_required: # level up
		collected_experience -= exp_required - current_experience
		experience_level += 1
		current_experience = 0
		exp_required = calculate_experience_cap()
		gui.level_up()
	else:
		current_experience += collected_experience
		collected_experience = 0
	gui.set_expbar(current_experience, exp_required)

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


## called by enemy_spawner to update the time
func change_time(argtime = 0):
	gui.change_time(argtime)
