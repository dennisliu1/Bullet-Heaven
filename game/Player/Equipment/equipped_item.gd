## Basically an Action
extends Node2D

@export var equipment_data: EquipmentData

@export var action_data: EntityAction

@onready var action_delay_timer = $ActionDelayTimer
@onready var action_reload_timer = $ActionReloadTimer
@export var enemy_detect_area : Area2D

#@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")


var attack_instances = {}
#var compiled_attack = []

@onready var attacks_group = $Attacks
var current_attack = 0
var attack_queue = []

func _ready():
#	_setup_test_attack()
	start_attack_sequence()


func set_equipped_item(equipped_data):
	if not equipped_data is EquipmentData:
		reset_attack_sequence()
		return
	
	equipment_data = equipped_data
	var new_action_data = EntityAction.new()
	new_action_data.action_delay = equipment_data.action_delay
	new_action_data.reload_time = equipment_data.reload_time
	action_data = new_action_data
	
	var spell_slots = equipment_data.spell_slots
	for i in range(spell_slots.size()):
		if spell_slots[i] != ItemData.EMPTY_ITEM_DATA:
			_add_spellcard_effect(spell_slots[i])
	reset_attack_sequence()

func remove_equipped_item():
	# don't need to save spellcards to equipped_item, taken cared of
	# by equipment_container
	var spell_slots = equipment_data.spell_slots
	for i in range(spell_slots.size()):
		if spell_slots[i] != ItemData.EMPTY_ITEM_DATA:
			remove_spellcard_effect(spell_slots[i])
	
	action_data.queue_free()
	equipment_data = null
	reset_attack_sequence()

func add_spellcard_effect(spellcard_effect):
	_add_spellcard_effect(spellcard_effect)
	reset_attack_sequence()

func remove_spellcard_effect(spellcard):
	var attack_instance = attack_instances[spellcard.key]
	attacks_group.remove_child(attack_instance)

	var remove_index = attack_queue.find(attack_instance)
	if remove_index >= 0 and remove_index < attack_queue.size():
		attack_queue.remove_at(remove_index)

	attack_instance.queue_free()


func _add_spellcard_effect(spellcard_effect):
	if spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE or spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
		var attack_object = load(SpellCardEffect.get_attack_type(spellcard_effect.attack_type))
		var attack_instance = attack_object.instantiate()
		attack_instance.setup_attack(spellcard_effect, Callable(self, "get_start_position"), Callable(self, "get_direction"))
		
		var entity_attack = EntityAttack.new()
		entity_attack.attack_properties = spellcard_effect
#		attack_instance.entity_attack = entity_attack
		
		attack_instances[spellcard_effect.key] = attack_instance
		attacks_group.add_child(attack_instance)
		attack_queue.append(attack_instance)
		return attack_instance
	elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.SUMMON:
		var attack_object = load(SpellCardEffect.get_attack_type(spellcard_effect.attack_type))
		var attack_instance = attack_object.instantiate()
		attack_instance.setup_attack(spellcard_effect, Callable(self, "get_start_position"), Callable(self, "get_direction"))
		
		var entity_attack = EntityAttack.new()
		entity_attack.attack_properties = spellcard_effect
#		attack_instance.entity_attack = entity_attack
		
		attack_instances[spellcard_effect.key] = attack_instance
		attacks_group.add_child(attack_instance)
		attack_instance.do_attack() # do one manual attack to spawn the object in
#		attack_queue.append(attack_instance)
		return attack_instance
	return null

func get_start_position():
	return player.position

func get_direction():
	return player.last_movement

# --- do attacks ---

func reset_attacks():
	reset_attack_sequence()

func start_attack_sequence():
	current_attack = 0
	do_attack()
	pass

func _on_action_delay_timer_timeout():
	do_attack()

func do_attack():
	if attack_queue.size() <= current_attack:
		return
	
	attack_queue[current_attack].do_attack() # TODO
	current_attack += 1
	
	## Start the next attack.
	## If we reached the end of the attacks, restart the loop
	if current_attack < attack_queue.size():
		action_delay_timer.wait_time = attack_queue[current_attack].attack_properties.action_delay + action_data.action_delay
		action_delay_timer.start()
		action_reload_timer.stop()
	else:
		action_reload_timer.start()

func _on_action_reload_timer_timeout():
	start_attack_sequence()

func stop_attack_sequence():
	action_delay_timer.stop()
	action_reload_timer.stop()
	current_attack = 0

func reset_attack_sequence():
	stop_attack_sequence()
	start_attack_sequence()

func _setup_test_attack():
	## Get spellcard data
	var spellcard_attack = SpellCardEffect.new()
	spellcard_attack.damage = 5
	spellcard_attack.action_delay = 0.5
	spellcard_attack.attack_type = "ice_spear"
	spellcard_attack.key = "ice_spear"
	spellcard_attack.sub_type = ItemData.ITEM_SUB_TYPE.PROJECTILE

	## Get EntityAction, stored in this class
	var equip_data = EquipmentData.new()
	equip_data.action_delay = 1
	equip_data.reload_time = 2
	equip_data.spell_slots.append(spellcard_attack)
	set_equipped_item(equip_data)

















