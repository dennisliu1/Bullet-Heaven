## Basically an Action
extends Node2D

@export var equipment_data: EquipmentData

@export var action_data: EntityAction

@onready var action_delay_timer = $ActionDelayTimer
@onready var action_reload_timer = $ActionReloadTimer
@export var enemy_detect_area : Area2D

#@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

var effect_queue = []
var effect_dict = {}


var attack_instances = {}

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
	
	# TODO need to update this, this is wrong
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

func sync_bulk_spellcard_effects(instance_stack):
	for instance_effect in instance_stack:
		if instance_effect.key in effect_dict:
			effect_dict[instance_effect.key].delete = false
			update_effect(instance_effect.key, instance_effect)
		else:
			effect_dict[instance_effect.key] = {
				"delete": false,
				"effect": instance_effect,
				"attack": _add_spellcard_effect(instance_effect),
				"index": effect_queue.size(),
			}
			effect_queue.append(instance_effect.key)
	for i in range(effect_queue.size()):
		var effect_key = effect_queue[i]
		if effect_dict[effect_key].delete:
			remove_spellcard_effect(effect_dict[effect_key].effect)
		else:
			# reset the flag ahead of time, no need to do another pass
			effect_dict[effect_key].delete = true
			
			# reset (re-enable) all attacks, will disable them
			effect_dict[effect_key].attack.attack_enabled = true

	# Do multi-cast and mod_projectile_modifiers
	for i in range(effect_queue.size()):
		var effect_key = effect_queue[i]
		var spellcard_effect = effect_dict[effect_key].effect
		if spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
			# Clear existing multi-cast and mod_projectile_modifier connections 
			effect_dict[effect_key].attack.entity_attacks.clear()

			# Add new connections
			for j in range(spellcard_effect.required_effects):
				var other_index = i+1+j
				if other_index < effect_queue.size():
					var other_key = effect_queue[other_index]
					var other_entry = effect_dict[other_key]
					effect_dict[effect_key].attack.entity_attacks.append(other_entry.attack)
					
					# disable the other attack
					other_entry.attack.attack_enabled = false

	reset_attack_sequence()

func add_spellcard_effect(spellcard_effect):
	_add_spellcard_effect(spellcard_effect)
	reset_attack_sequence()

func remove_spellcard_effect(spellcard_effect):
	var attack_instance = attack_instances[spellcard_effect.key]
	attacks_group.remove_child(attack_instance)

	var remove_index = attack_queue.find(attack_instance)
	if remove_index >= 0 and remove_index < attack_queue.size():
		attack_queue.remove_at(remove_index)
	
	effect_queue.remove_at(effect_dict[spellcard_effect.key].index)
	effect_dict.erase(spellcard_effect.key)

	attack_instance.queue_free()


func _add_spellcard_effect(spellcard_effect):
	if spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
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
	if spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
		var attack_object = load("res://Utility/entity_mod_attack.tscn")
		var attack_instance = attack_object.instantiate()
#		attack_instance.setup_attack(spellcard_effect, Callable(self, "get_start_position"), Callable(self, "get_direction"))
		
		var entity_attack = EntityAttack.new()
		entity_attack.attack_properties = spellcard_effect
		
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
	action_delay_timer.start()
	pass

func _on_action_delay_timer_timeout():
	do_attack()

func do_attack():
	if attack_queue.size() <= current_attack:
		return
	
	if attack_queue[current_attack].attack_enabled:
		attack_queue[current_attack].do_attack()
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
	current_attack = 0
	do_attack()
	action_reload_timer.stop()

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

# ---

func update_effect(key, instance_effect):
	effect_dict[key].effect.required_effects = instance_effect.required_effects
	effect_dict[key].effect.energy_drain = instance_effect.energy_drain
	effect_dict[key].effect.damage = instance_effect.damage
	effect_dict[key].effect.action_delay = instance_effect.action_delay
	effect_dict[key].effect.num_attacks = instance_effect.num_attacks
	effect_dict[key].effect.attack_angle = instance_effect.attack_angle
	effect_dict[key].effect.spread = instance_effect.spread
	effect_dict[key].effect.velocity = instance_effect.velocity
	effect_dict[key].effect.lifetime = instance_effect.lifetime
	effect_dict[key].effect.radius = instance_effect.radius
	effect_dict[key].effect.knockback = instance_effect.knockback
	effect_dict[key].effect.pierce = instance_effect.pierce
	effect_dict[key].effect.bounce = instance_effect.bounce
	effect_dict[key].effect.hit_hp = instance_effect.hit_hp
	effect_dict[key].effect.hit_size = instance_effect.hit_size
	
	effect_dict[key].effect.on_hit_effects.clear()
	for on_hit_effect in instance_effect.on_hit_effects:
		effect_dict[key].effect.on_hit_effects.append(on_hit_effect)















