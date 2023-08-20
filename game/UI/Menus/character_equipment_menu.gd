extends Control

@onready var equipment_inventory_data = $EquipmentSelection/EquipmentInventoryData
@onready var equipment_inventory_menu = $EquipmentSelection/EquipmentInventoryMenu
@onready var spell_inventory_data = $SpellSelection/SpellInventoryData
@onready var spell_inventory_menu = $SpellSelection/SpellInventoryMenu

var selected_equipment_index = -1
var selected_equipment_item_slot = null
var selected_spell_index = -1
var selected_spell_item_slot = null

func _ready():
	for item_slot in equipment_inventory_menu.get_children():
		var index = item_slot.get_index()
		item_slot.gui_input.connect(_on_ItemSlot_gui_input.bind(item_slot, index))
	# pre-select the first equipment
	selected_equipment_item_slot = equipment_inventory_menu.get_child(0)
	selected_equipment_item_slot.select_item()
	selected_equipment_index = 0

	for item_slot in spell_inventory_menu.get_children():
		var index = item_slot.get_index()
		item_slot.gui_input.connect(_on_ItemSlot_gui_input.bind(item_slot, index))
	# pre-select the first spell
	selected_spell_item_slot = spell_inventory_menu.get_child(0)
	selected_spell_item_slot.select_item()
	selected_spell_index = 0


func _on_back_button_click_end():
	var character_select_menu = "res://UI/Menus/character_select_menu.tscn"
	var _level = get_tree().change_scene_to_file(character_select_menu)

func _on_next_button_click_end():
	save_starting_items()
	var world_game = "res://World/world.tscn"
	var _level = get_tree().change_scene_to_file(world_game)

func save_starting_items():
	StartingGameData.add_starting_equipment(equipment_inventory_data.items[selected_spell_index])
	StartingGameData.add_starting_spell(spell_inventory_data.items[selected_spell_index])

func _on_ItemSlot_gui_input(event, item_slot, index):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if item_slot.inventory_data == spell_inventory_data:
				select_spell_item(item_slot, index)
			elif item_slot.inventory_data == equipment_inventory_data:
				select_equipment_item(item_slot, index)

func select_spell_item(item_slot, index):
	if spell_inventory_data.items[index] == ItemData.EMPTY_ITEM_DATA:
		return
	
	# the player can only pick one, so unselect the previous item
	selected_spell_item_slot.unselect_item()
	
	# select the item
	item_slot.select_item()
	selected_spell_index = index
	selected_spell_item_slot = item_slot

func select_equipment_item(item_slot, index):
	if equipment_inventory_data.items[index] == ItemData.EMPTY_ITEM_DATA:
		return
	
	# the player can only pick one, so unselect the previous item
	selected_equipment_item_slot.unselect_item()
	
	# select the item
	item_slot.select_item()
	selected_equipment_index = index
	selected_equipment_item_slot = item_slot
