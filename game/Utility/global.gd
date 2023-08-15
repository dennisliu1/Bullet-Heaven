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
	data_array[data_path][key].sub_type = ItemData.get_sub_type(json_data.data.sub_type)
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

func populate_spellcard_data(target_data, json_spellcard):
	if json_spellcard.data.has("energy_drain"):
		target_data.energy_drain = json_spellcard.data.energy_drain
	if json_spellcard.data.has("damage"): # TODO should handle multiple damages
		target_data.damage = json_spellcard.data.damage
	if json_spellcard.data.has("damage_shock"):
		target_data.damage_shock = json_spellcard.data.damage_shock
	if json_spellcard.data.has("damage_fire"):
		target_data.damage_fire = json_spellcard.data.damage_fire
	if json_spellcard.data.has("damage_ice"):
		target_data.damage_ice = json_spellcard.data.damage_ice
	if json_spellcard.data.has("damage_poison"):
		target_data.damage_poison = json_spellcard.data.damage_poison
	if json_spellcard.data.has("damage_soul"):
		target_data.damage_soul = json_spellcard.data.damage_soul
	if json_spellcard.data.has("action_delay"):
		target_data.action_delay = json_spellcard.data.action_delay
	if json_spellcard.data.has("num_attacks"):
		target_data.num_attacks = json_spellcard.data.num_attacks
	if json_spellcard.data.has("attack_angle"):
		target_data.attack_angle = json_spellcard.data.attack_angle
	if json_spellcard.data.has("spread"):
		target_data.spread = json_spellcard.data.spread
	if json_spellcard.data.has("velocity"):
		target_data.velocity = json_spellcard.data.velocity
	if json_spellcard.data.has("lifetime"):
		target_data.lifetime = json_spellcard.data.lifetime
	if json_spellcard.data.has("radius"):
		target_data.radius = json_spellcard.data.radius
	if json_spellcard.data.has("knockback"):
		target_data.knockback = json_spellcard.data.knockback
	if json_spellcard.data.has("pierce"):
		target_data.pierce = json_spellcard.data.pierce
	if json_spellcard.data.has("bounce"):
		target_data.bounce = json_spellcard.data.bounce
	if json_spellcard.data.has("hit_hp"):
		target_data.hit_hp = json_spellcard.data.hit_hp
	if json_spellcard.data.has("hit_size"):
		target_data.hit_size = json_spellcard.data.hit_size
	if json_spellcard.data.has("attack_type"):
		target_data.attack_type = json_spellcard.data.attack_type
	if json_spellcard.data.has("hit_type"):
		target_data.hit_type = json_spellcard.data.hit_type
	if json_spellcard.data.has("hit_spawn_type"):
		target_data.hit_spawn_type = SpellCardData.get_hit_spawn_type(json_spellcard.data.hit_spawn_type)
	if json_spellcard.data.has("hit_behavior_type"):
		target_data.hit_behavior_type = SpellCardData.get_hit_behavior_type(json_spellcard.data.hit_behavior_type)
	if json_spellcard.data.has("on_fire_effect"):
		for on_fire_spellcard_data in json_spellcard.data.on_fire_effect:
			var spellcard_effect = populate_spellcard_data(SpellCardData.new(), on_fire_spellcard_data)
			target_data.on_fire_effect.append(spellcard_effect)
	if json_spellcard.data.has("on_hit_effect"):
		for on_hit_spellcard_data in json_spellcard.data.on_hit_effect:
			var spellcard_effect = populate_spellcard_data(SpellCardData.new(), on_hit_spellcard_data)
			target_data.on_hit_effect.append(spellcard_effect)
	return target_data
