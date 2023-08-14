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

var evaluated_spellcards

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
	_save_spellcard_data()
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
func _on_spellcard_set(new_spellcards):
	for i in range(new_spellcards.size()):
		if new_spellcards[i] is SpellCardData:
			new_spellcards[i].equipment = equipment_data
#			_add_action(new_spellcards[i])
	
#	_save_spellcard_data()
	evaluated_spellcards = evaluate_spellcards(spellcard_inventory_data.items)
	_add_evaluated_spell_attacks()

func _add_action(spellcard):
	if spellcard.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
		player.add_attack_by_spellcard(spellcard, get_index())
	elif spellcard.sub_type == ItemData.ITEM_SUB_TYPE.SUMMON:
		player.add_attack_by_spellcard(spellcard, get_index())

## Clear the associated equipment, we only want to set this if
## the spellcard is actually socketed into an equipment
func _on_spellcard_removed(spellcards):
	for i in range(spellcards.size()):
		if spellcards[i] is SpellCardData:
			spellcards[i].equipment = ItemData.EMPTY_ITEM_DATA
#			player.remove_spellcard(spellcards[i], get_index())
	_remove_evaluated_spell_attacks()
	
#	_save_spellcard_data()
	evaluated_spellcards = evaluate_spellcards(spellcard_inventory_data.items)
	_add_evaluated_spell_attacks()

func display_equipment():
	equipment_slot.display_item(equipment_data)


func _on_visibility_changed():
	# honestly, i only need to do this once
	# TODO make a new class that inherits GridContainer, it won't hide it
	# by default (inventory_menu hides it by default)
	equipment_slot.visible = true
	spellcard_sockets.visible = true

func _save_spellcard_data():
	if equipment_data != ItemData.EMPTY_ITEM_DATA:
		for i in range(spellcard_inventory_data.slots):
			equipment_data.spell_slots[i] = spellcard_inventory_data.items[i]

func _remove_evaluated_spell_attacks():
	for spellcard in evaluated_spellcards:
		if spellcard is SpellCardData and spellcard.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
			player.remove_spellcard(spellcard, get_index())

func _add_evaluated_spell_attacks():
	for i in range(evaluated_spellcards.size()):
		if evaluated_spellcards[i] is SpellCardData:
			evaluated_spellcards[i].equipment = equipment_data
			_add_action(evaluated_spellcards[i])

# ---

func evaluate_spellcards(spellcards: Array):
	var stack = []
	for spellcard in spellcards:
		var new_spellcard = spellcard.duplicate()

		if spellcard == ItemData.EMPTY_ITEM_DATA:
			continue

		if stack.size() <= 0:
			stack.append(new_spellcard)
			continue

		## the conditions are based on the top card and the spellcard.
		var is_looping = true
		while is_looping:
			## if the stack is empty, add the spellcard directly
			if stack.size() <= 0:
				stack.append(new_spellcard)
				is_looping = false
				continue

			var top_card : SpellCardData = stack[stack.size()-1]
			var top_card_sub_type = top_card.sub_type
			if new_spellcard.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
				if top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
					## top = projectile + spellcard = projectile
					## cannot combine, append the projectile
					stack.append(new_spellcard)
					is_looping = false
				elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
					## top = modifier + spellcard = projectile
					## add modifier to spellcard
					apply_modifier_to_spellcard(new_spellcard, top_card)
					stack.pop_back()
				elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
					apply_modifier_to_spellcard(new_spellcard, top_card)
					stack.pop_back()
	return stack

func apply_modifier_to_spellcard(spellcard: SpellCardData, modifier_card: SpellCardData):
	if modifier_card.get("damage"):
		spellcard.damage *= modifier_card.damage
	if modifier_card.get("damage_shock"):
		spellcard.damage_shock *= modifier_card.damage_shock
	if modifier_card.get("damage_fire"):
		spellcard.damage_fire *= modifier_card.damage_fire
	if modifier_card.get("damage_ice"):
		spellcard.damage_ice *= modifier_card.damage_ice
	if modifier_card.get("damage_poison"):
		spellcard.damage_poison *= modifier_card.damage_poison
	if modifier_card.get("damage_soul"):
		spellcard.damage_soul *= modifier_card.damage_soul
	if modifier_card.get("action_delay"):
		spellcard.action_delay *= modifier_card.action_delay
	if modifier_card.get("num_attacks"):
		spellcard.num_attacks += modifier_card.num_attacks
	if modifier_card.get("spread"):
		spellcard.spread *= modifier_card.spread
	if modifier_card.get("velocity"):
		spellcard.velocity *= modifier_card.velocity
	if modifier_card.get("lifetime"):
		spellcard.lifetime *= modifier_card.lifetime
	if modifier_card.get("radius"):
		spellcard.radius *= modifier_card.radius
	if modifier_card.get("knockback"):
		spellcard.knockback *= modifier_card.knockback
	if modifier_card.get("pierce"):
		spellcard.pierce *= modifier_card.pierce
	if modifier_card.get("bounce"):
		spellcard.bounce *= modifier_card.bounce
	if modifier_card.get("hit_hp"):
		spellcard.hit_hp *= modifier_card.hit_hp
	if modifier_card.get("hit_size"):
		spellcard.hit_size *= modifier_card.hit_size
	if modifier_card.get("on_fire_effect"):
		spellcard.on_fire_effect = []
		for spellcard_effect in modifier_card.on_fire_effect:
			spellcard.on_fire_effect.append(spellcard_effect.duplicate())
