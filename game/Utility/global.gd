extends Node

var data_array = {}

var modifiers

const ICON_PATH = "res://Player/Modifiers/Textures/noita spells/%s"

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
		data_array[data_path] = read_from_JSON(data_path)
		for key in data_array[data_path].keys():
			data_array[data_path][key]["key"] = key
	return data_array[data_path]
