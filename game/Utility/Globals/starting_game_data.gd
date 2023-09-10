## This file stores data from the character selection screen and item selection
## and is used to initialize the game world.
extends Node

var starting_equipment = []
var starting_spells = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func reset_starting_equipment():
	starting_equipment.clear()

func reset_starting_spells():
	starting_spells.clear()

func add_starting_equipment(item):
	starting_equipment.append(item)

func add_starting_spell(item):
	starting_spells.append(item)

func get_starting_equipment():
	return starting_equipment

func get_starting_spells():
	return starting_spells


