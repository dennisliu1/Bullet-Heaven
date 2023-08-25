extends Node2D

var effect_dict = {}
var effect_queue = []

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var player_container = $PlayerContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func sync_bulk_spellcard_effects(instance_stack: Array[SpellCardEffect]):
	# Clear the queue, the order might have changed
	effect_queue.clear()

	# Create or update existing attack data
	## update order of the effects, they matter
	for spellcard_effect in instance_stack:
		if spellcard_effect.key in effect_dict:
			effect_dict[spellcard_effect.key].delete = false
			update_effect(spellcard_effect.key, spellcard_effect)
		else:
			effect_dict[spellcard_effect.key] = {
				"delete": false,
				"effect": spellcard_effect,
				"attack": _create_spellcard_effect(spellcard_effect),
			}
		# update the index
		effect_dict[spellcard_effect.key].index = effect_queue.size()
		effect_queue.append(spellcard_effect.key)
	
	# delete any effects that were removed
	for effect_key in effect_dict.keys():
		if effect_dict[effect_key].delete:
			remove_spellcard_effect(effect_key)
		else:
			# reset the flag ahead of time, no need to do another pass
			effect_dict[effect_key].delete = true
			
			# reset (re-enable) all attacks, will disable them
			effect_dict[effect_key].attack.enable_attack()

	# connect multi-cast and mod_projectile_modifiers
	## Clear multi-cast and mod_projectile_modifiers
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
					other_entry.attack.disable_attack()
	for effect_instance in player_container.get_children():
		effect_instance.setup_effect()

func reset_spellcard_effects():
	effect_queue.clear()
	effect_dict.clear()
	for effect_instance in player_container.get_children():
		effect_instance.queue_free()
	pass

func update_effect(key, spellcard_effect):
	SpellCardEffect.update_effect(effect_dict[key].effect, spellcard_effect)
	effect_dict[key].attack.update_effects()

func _create_spellcard_effect(spellcard_effect):
	if spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
		var attack_object = load(SpellCardEffect.get_attack_type(spellcard_effect.attack_type))
		var attack_instance = attack_object.instantiate()
		attack_instance.setup_attack(spellcard_effect, Callable(self, "get_start_position"), Callable(self, "get_direction"))
		player_container.add_child(attack_instance)
		return attack_instance
	elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
		var attack_object = load("res://Utility/entity_mod_attack.tscn")
		var attack_instance = attack_object.instantiate()
		attack_instance.setup_attack(spellcard_effect, Callable(self, "get_start_position"), Callable(self, "get_direction"))
		player_container.add_child(attack_instance)
		return attack_instance
	else:
		return null

func get_start_position():
	return player.position

func get_direction():
	return player.last_movement

func remove_spellcard_effect(key):
	var spellcard_dict_data = effect_dict[key]
	
	# remove the effect pointers
	
	# remove effect_node
	# sometimes the card might not have an attack
	if spellcard_dict_data.attack:
		spellcard_dict_data.attack.queue_free()
	
	# remove the data
	# No need to update the other index values, they use the incoming data
	# to set, so it will be up to date.
	# Same with the queue, it only has up to date data.
	effect_dict.erase(key)

# reset all attacks
func reset_attacks():
	for effect_instance in player_container.get_children():
		effect_instance.reset_attack()

func pause_attacks():
	for effect_instance in player_container.get_children():
		effect_instance.pause_attack()

func unpause_attacks():
	for effect_instance in player_container.get_children():
		effect_instance.unpause_attack()














