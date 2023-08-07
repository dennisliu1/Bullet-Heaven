extends Node

var data_array = {}

var modifiers

const ICON_PATH = "res://Player/Modifiers/Textures/noita spells/%s"

var icon_data = preload("res://Utility/item_data.gd")

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
				populate_equipment_data(data_path, key, json_data)
			elif data_array[data_path][key] is SpellCardData:
				populate_spellcard_data(data_path, key, json_data)
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

func populate_equipment_data(data_path, key, json_data):
	data_array[data_path][key].num_slots = json_data[key].data.slots # not sure about this...
	for i in range(json_data[key].data.slots):
		data_array[data_path][key].spell_slots.append(ItemData.EMPTY_ITEM_DATA)
	
	if json_data[key].data.has("energy"):
		data_array[data_path][key].energy = json_data[key].data.energy
	if json_data[key].data.has("action_delay"):
		data_array[data_path][key].action_delay = json_data[key].data.action_delay
	if json_data[key].data.has("recharge_speed"):
		data_array[data_path][key].recharge_speed = json_data[key].data.recharge_speed
	if json_data[key].data.has("recharge_speed_type"):
		data_array[data_path][key].recharge_speed_type = EquipmentData.get_energy_recharge_type(json_data[key].data.recharge_speed_type)
	if json_data[key].data.has("reload_time"):
		data_array[data_path][key].reload_time = json_data[key].data.reload_time
	if json_data[key].data.has("spread"):
		data_array[data_path][key].spread = json_data[key].data.spread
	if json_data[key].data.has("velocity"):
		data_array[data_path][key].velocity = json_data[key].data.velocity
	if json_data[key].data.has("protection"):
		data_array[data_path][key].protection = json_data[key].data.protection

func populate_spellcard_data(data_path, key, json_data):
	if json_data[key].data.has("energy_drain"):
		data_array[data_path][key].energy_drain = json_data[key].data.energy_drain
	if json_data[key].data.has("damage"): # TODO should handle multiple damages
		data_array[data_path][key].damage = json_data[key].data.damage
	if json_data[key].data.has("action_delay"):
		data_array[data_path][key].action_delay = json_data[key].data.action_delay
	if json_data[key].data.has("num_attacks"):
		data_array[data_path][key].num_attacks = json_data[key].data.num_attacks
	if json_data[key].data.has("spread"):
		data_array[data_path][key].spread = json_data[key].data.spread
	if json_data[key].data.has("velocity"):
		data_array[data_path][key].velocity = json_data[key].data.velocity
	if json_data[key].data.has("lifetime"):
		data_array[data_path][key].lifetime = json_data[key].data.lifetime
	if json_data[key].data.has("radius"):
		data_array[data_path][key].radius = json_data[key].data.radius
	if json_data[key].data.has("knockback"):
		data_array[data_path][key].knockback = json_data[key].data.knockback
	if json_data[key].data.has("pierce"):
		data_array[data_path][key].pierce = json_data[key].data.pierce
	if json_data[key].data.has("bounce"):
		data_array[data_path][key].bounce = json_data[key].data.bounce
	if json_data[key].data.has("attack_type"):
		data_array[data_path][key].attack_type = json_data[key].data.attack_type
