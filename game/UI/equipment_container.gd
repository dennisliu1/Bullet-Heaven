extends Control
class_name EquipmentContainer

@onready var equipment_name = $EquipmentName
@onready var equipment_slot = $EquipmentSlot
@onready var equipment_inventory_data = $EquipmentInventoryData
@onready var spellcard_inventory_data = $SpellcardInventoryData
@onready var spellcard_sockets = $SpellcardSockets
@onready var background_rect = $BackgroundRect


@onready var drag_preview : DragPreview = get_tree().get_first_node_in_group("drag_preview")
@onready var tooltip : Control = get_tree().get_first_node_in_group("tooltip")

var equipment_data

## Called when the node enters the scene tree for the first time.
func _ready():
	equipment_data = equipment_inventory_data.items[0]

#	var item_slot = equipment_slot.get_node("item_slot")
	equipment_inventory_data.items_changed.connect(_on_equipment_changed)
	
#	equipment_slot.display_modifier_slots()
#	spellcard_sockets.display_modifier_slots()
#	copy_spellcard_data()

## copy equipment's spellcard slot data over into the spellcard_sockets
## if equipment_data is empty, don't try populating spellcards
func copy_spellcard_data():
	if equipment_data is EquipmentData:
		spellcard_inventory_data.set_bulk(equipment_data.spell_slots, equipment_data.num_slots)

func _on_equipment_changed(_indexes):
	# TODO when switching equipment out, we need to save the data
	# back into the equipment_data variable
	if equipment_data != ItemData.EMPTY_ITEM_DATA:
		for i in range(spellcard_inventory_data.slots):
			equipment_data.spell_slots[i] = spellcard_inventory_data.items[i]
	
	equipment_data = equipment_inventory_data.items[0]
#	display_equipment()

	if equipment_data != ItemData.EMPTY_ITEM_DATA:
		copy_spellcard_data()
		spellcard_sockets.clear_children()
		spellcard_sockets.display_modifier_slots()
		for item_slot in spellcard_sockets.get_children():
			drag_preview.bind_item_slot(item_slot)
			tooltip.bind_item_slot(item_slot)
	else:
		spellcard_inventory_data.set_bulk([], 0)
		spellcard_sockets.clear_children()
#		spellcard_sockets.display_modifier_slots()

func display_equipment():
	equipment_slot.display_item(equipment_data)


func _on_visibility_changed():
	# honestly, i only need to do this once
	# TODO make a new class that inherits GridContainer, it won't hide it
	# by default (inventory_menu hides it by default)
	equipment_slot.visible = true
	spellcard_sockets.visible = true
#	equipment_slot.visible = 
