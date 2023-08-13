extends Control
class_name EquipmentContainer


@onready var equipment_name = $EquipmentName
@onready var equipment_slot = $EquipmentSlot
@onready var equipment_inventory_data = $EquipmentInventoryData
@onready var spellcard_inventory_data = $SpellcardInventoryData
@onready var spellcard_sockets = $SpellcardSockets
@onready var background_rect = $BackgroundRect

@onready var player = get_tree().get_first_node_in_group("player")
@onready var drag_preview : DragPreview = get_tree().get_first_node_in_group("drag_preview")
@onready var tooltip : Control = get_tree().get_first_node_in_group("tooltip")

var attack_instances = {}

var equipment_data

## Called when the node enters the scene tree for the first time.
func _ready():
	equipment_data = equipment_inventory_data.items[0]

#	var item_slot = equipment_slot.get_node("item_slot")
	equipment_inventory_data.items_changed.connect(_on_equipment_changed)
	spellcard_inventory_data.items_set.connect(_on_spellcard_set)
	spellcard_inventory_data.items_removed.connect(_on_spellcard_removed)
	
#	equipment_slot.display_modifier_slots()
#	spellcard_sockets.display_modifier_slots()
#	copy_spellcard_data_to_inventory()

## copy equipment's spellcard slot data over into the spellcard_sockets
## if equipment_data is empty, don't try populating spellcards
func copy_spellcard_data_to_inventory():
	if equipment_data is EquipmentData:
		spellcard_inventory_data.set_bulk(equipment_data.spell_slots, equipment_data.num_slots)
		

func _on_equipment_changed(_indexes):
	save_spellcard_data()
	equipment_data = equipment_inventory_data.items[0]
	if equipment_data != ItemData.EMPTY_ITEM_DATA:
		copy_spellcard_data_to_inventory()
		spellcard_sockets.clear_children()
		spellcard_sockets.display_modifier_slots()
		for item_slot in spellcard_sockets.get_children():
			drag_preview.bind_item_slot(item_slot)
			tooltip.bind_item_slot(item_slot)
	else:
		spellcard_inventory_data.set_bulk([], 0)
		spellcard_sockets.clear_children()
	player.set_equipped_item(equipment_data, get_index())

## associate all newly added spellcards with the equipment.
## They are socketed to the equipment now.
func _on_spellcard_set(spellcards):
	for i in range(spellcards.size()):
		if spellcards[i] is SpellCardData:
			spellcards[i].equipment = equipment_data
			add_action(spellcards[i])

func add_action(spellcard):
	if spellcard.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
		player.add_attack_by_spellcard(spellcard, get_index())
#		var attack_object = load(SpellCardData.get_attack_type(spellcard.attack_type))
#		var attack_instance = attack_object.instantiate()
#		attack_instances[spellcard.key] = attack_instance
#		player.add_attack(attack_instance, get_index())
	elif spellcard.sub_type == ItemData.ITEM_SUB_TYPE.SUMMON:
		player.add_attack_by_spellcard(spellcard, get_index())

## Clear the associated equipment, we only want to set this if
## the spellcard is actually socketed into an equipment
func _on_spellcard_removed(spellcards):
	for i in range(spellcards.size()):
		if spellcards[i] is SpellCardData:
			spellcards[i].equipment = ItemData.EMPTY_ITEM_DATA
			player.remove_spellcard(spellcards[i], get_index())
#			attack_instances[spellcards[i].key].queue_free()

func display_equipment():
	equipment_slot.display_item(equipment_data)


func _on_visibility_changed():
	# honestly, i only need to do this once
	# TODO make a new class that inherits GridContainer, it won't hide it
	# by default (inventory_menu hides it by default)
	equipment_slot.visible = true
	spellcard_sockets.visible = true

func save_spellcard_data():
	if equipment_data != ItemData.EMPTY_ITEM_DATA:
		for i in range(spellcard_inventory_data.slots):
			equipment_data.spell_slots[i] = spellcard_inventory_data.items[i]
