extends Node

var data_array = {}

var modifiers

# Called when the node enters the scene tree for the first time.
func _ready():
	modifiers = read_from_JSON("res://Player/Modifiers/modifiers.json")
	
	# Store the key as a key field as well, so we can do lookups?
	for key in modifiers.keys():
		modifiers[key]["key"] = key

func read_from_JSON(path):
	var json_string = FileAccess.get_file_as_string(path)
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}

## Gets a modifier by key, returns a duplicate copy of the data.
func get_modifier_by_key(key):
	if modifiers and modifiers.has(key):
		return modifiers[key].duplicate(true)

func get_object_by_key(data_path: String, key: String):
	var data_object = get_data(data_path)
	if data_object and data_object.has(key):
		return data_array[data_path][key].duplicate(true)

func get_data(data_path: String):
	if not data_array.has(data_path):
		var json_data = read_from_JSON(data_path)
		data_array[data_path] = {}
		
		for key in json_data.keys():
			data_array[data_path][key] = create_item_data_type(json_data[key].type)
			insert_json_data(data_path, key, json_data[key])
			if data_array[data_path][key] is EquipmentData:
				populate_equipment_data(data_array[data_path][key], json_data[key])
			elif data_array[data_path][key] is SpellCardData:
				
				populate_spellcard_data(data_array[data_path][key], json_data[key])
	return data_array[data_path]

func insert_json_data(data_path, key, json_data):
	data_array[data_path][key].name = json_data.name
	data_array[data_path][key].texture = load(json_data.path + json_data.icon)
	data_array[data_path][key].type = ItemData.get_type(json_data.type)
	# need to move this out?
	data_array[data_path][key].key = key

func create_item_data_type(type_str):
	var type = ItemData.get_type(type_str)
	var result = ItemData.EMPTY_ITEM_DATA
	match type:
		ItemData.ITEM_TYPE.EQUIPMENT:
			return EquipmentData.new()
		ItemData.ITEM_TYPE.SPELLCARD:
			return SpellCardData.new()
	return result

func populate_equipment_data(target_data, json_spellcard):
	target_data.num_slots = json_spellcard.data.slots # not sure about this...
	for i in range(json_spellcard.data.slots):
		target_data.spell_slots.append(ItemData.EMPTY_ITEM_DATA)
	
	if json_spellcard.data.has("energy"):
		target_data.energy = json_spellcard.data.energy
	if json_spellcard.data.has("action_delay"):
		target_data.action_delay = json_spellcard.data.action_delay
	if json_spellcard.data.has("recharge_speed"):
		target_data.recharge_speed = json_spellcard.data.recharge_speed
	if json_spellcard.data.has("recharge_speed_type"):
		target_data.recharge_speed_type = EquipmentData.get_energy_recharge_type(json_spellcard.data.recharge_speed_type)
	if json_spellcard.data.has("reload_time"):
		target_data.reload_time = json_spellcard.data.reload_time
	if json_spellcard.data.has("spread"):
		target_data.spread = json_spellcard.data.spread
	if json_spellcard.data.has("velocity"):
		target_data.velocity = json_spellcard.data.velocity
	if json_spellcard.data.has("protection"):
		target_data.protection = json_spellcard.data.protection

func populate_spellcard_data(spellcard_data, json_spellcard):
	for spellcard_data_effect in json_spellcard.data:
		var spellcard_effect = SpellCardEffect.new()
		populate_spellcard_effect(spellcard_effect, spellcard_data_effect)
		spellcard_data.effects.append(spellcard_effect)
	return spellcard_data

func populate_spellcard_effect(spellcard_effect, spellcard_data_effect):
	spellcard_effect.key = spellcard_effect.name
	if spellcard_data_effect.has("sub_type"):
		# defined in ItemData, but set it here cuz we used inheritance
		spellcard_effect.sub_type = SpellCardEffect.get_sub_type(spellcard_data_effect.sub_type)
	if spellcard_data_effect.has("energy_drain"):
		spellcard_effect.energy_drain = spellcard_data_effect.energy_drain
	if spellcard_data_effect.has("damage"): # TODO should handle multiple damages
		spellcard_effect.damage = spellcard_data_effect.damage
	if spellcard_data_effect.has("damage_shock"):
		spellcard_effect.damage_shock = spellcard_data_effect.damage_shock
	if spellcard_data_effect.has("damage_fire"):
		spellcard_effect.damage_fire = spellcard_data_effect.damage_fire
	if spellcard_data_effect.has("damage_ice"):
		spellcard_effect.damage_ice = spellcard_data_effect.damage_ice
	if spellcard_data_effect.has("damage_poison"):
		spellcard_effect.damage_poison = spellcard_data_effect.damage_poison
	if spellcard_data_effect.has("damage_soul"):
		spellcard_effect.damage_soul = spellcard_data_effect.damage_soul
	if spellcard_data_effect.has("action_delay"):
		spellcard_effect.action_delay = spellcard_data_effect.action_delay
	if spellcard_data_effect.has("num_attacks"):
		spellcard_effect.num_attacks = spellcard_data_effect.num_attacks
	if spellcard_data_effect.has("attack_angle"):
		spellcard_effect.attack_angle = spellcard_data_effect.attack_angle
	if spellcard_data_effect.has("spread"):
		spellcard_effect.spread = spellcard_data_effect.spread
	if spellcard_data_effect.has("velocity"):
		spellcard_effect.velocity = spellcard_data_effect.velocity
	if spellcard_data_effect.has("lifetime"):
		spellcard_effect.lifetime = spellcard_data_effect.lifetime
	if spellcard_data_effect.has("radius"):
		spellcard_effect.radius = spellcard_data_effect.radius
	if spellcard_data_effect.has("knockback"):
		spellcard_effect.knockback = spellcard_data_effect.knockback
	if spellcard_data_effect.has("pierce"):
		spellcard_effect.pierce = spellcard_data_effect.pierce
	if spellcard_data_effect.has("bounce"):
		spellcard_effect.bounce = spellcard_data_effect.bounce
	if spellcard_data_effect.has("hit_hp"):
		spellcard_effect.hit_hp = spellcard_data_effect.hit_hp
	if spellcard_data_effect.has("hit_size"):
		spellcard_effect.hit_size = spellcard_data_effect.hit_size
	if spellcard_data_effect.has("attack_type"):
		spellcard_effect.attack_type = spellcard_data_effect.attack_type
	if spellcard_data_effect.has("hit_type"):
		spellcard_effect.hit_type = spellcard_data_effect.hit_type
	if spellcard_data_effect.has("hit_spawn_type"):
		spellcard_effect.hit_spawn_type = SpellCardEffect.get_hit_spawn_type(spellcard_data_effect.hit_spawn_type)
	if spellcard_data_effect.has("hit_behavior_type"):
		spellcard_effect.hit_behavior_type = SpellCardEffect.get_hit_behavior_type(spellcard_data_effect.hit_behavior_type)
	if spellcard_data_effect.has("on_fire_effects"):
		for on_fire_spellcard_effect_data in spellcard_data_effect.on_fire_effects:
			var new_data = populate_spellcard_effect(SpellCardEffect.new(), on_fire_spellcard_effect_data)
			spellcard_effect.on_fire_effects.append(new_data)
	if spellcard_data_effect.has("on_hit_effects"):
		for on_hit_spellcard_effect_data in spellcard_data_effect.on_hit_effects:
			var new_data = populate_spellcard_effect(SpellCardEffect.new(), on_hit_spellcard_effect_data)
			spellcard_effect.on_hit_effects.append(new_data)
	return spellcard_effect
