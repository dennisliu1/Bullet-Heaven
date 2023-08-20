extends Node2D

## TODO change this to handle variable number of equipment slots
@onready var equipment_container = $UI/EquippedContainer/EquipmentContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_with_starting_items()

func _init_with_starting_items():
	for equipment in StartingGameData.get_starting_equipment():
		equipment_container.set_equipment(equipment)
	for spell in StartingGameData.get_starting_spells():
		equipment_container.add_spellcard(spell)
