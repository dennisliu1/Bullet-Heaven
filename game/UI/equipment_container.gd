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

var evaluated_spellcard_effects

## Called when the node enters the scene tree for the first time.
func _ready():
	equipment_data = equipment_inventory_data.items[0]
	equipment_inventory_data.inventory_type = InventoryData.INVENTORY_TYPE.EQUIPMENT_ONLY
	equipment_inventory_data.items_changed.connect(_on_equipment_changed)
	spellcard_inventory_data.inventory_type = InventoryData.INVENTORY_TYPE.SPELLS_ONLY
	spellcard_inventory_data.items_changed.connect(_on_spellcard_changed)

func set_equipment(item, index=0):
	equipment_inventory_data.set_item(index, item)

func add_spellcard(item):
	spellcard_inventory_data.add_item(item)

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
	refresh_equipped_item_data()

func _on_spellcard_changed(changed_spellcards):
	for i in range(changed_spellcards.size()):
		if changed_spellcards[i] is SpellCardData:
			changed_spellcards[i].equipment = equipment_data
	refresh_equipped_item_data()

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
	if not evaluated_spellcard_effects:
		return
	
	for spellcard_effect in evaluated_spellcard_effects:
		if spellcard_effect is SpellCardEffect and spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
			player.remove_spellcard_effect(spellcard_effect, get_index())

func _add_evaluated_spell_attacks():
	for i in range(evaluated_spellcard_effects.size()):
		if evaluated_spellcard_effects[i] is SpellCardEffect:
			_add_action(evaluated_spellcard_effects[i])

func _add_action(spellcard_effect):
	if spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
		player.add_attack_by_spellcard_effect(spellcard_effect, get_index())
	if spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
		player.add_attack_by_spellcard_effect(spellcard_effect, get_index())
	elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.SUMMON:
		player.add_attack_by_spellcard_effect(spellcard_effect, get_index())

func reset_attacks():
	player.reset_attacks(get_index())

func refresh_equipped_item_data():
	var instance_stack = refresh_evaluated_spellcard_effects()
	player.sync_bulk_spellcard_effects(instance_stack, get_index())

# ---

func refresh_evaluated_spellcard_effects():
	evaluated_spellcard_effects = evaluate_spellcards(spellcard_inventory_data.items)
	
	return add_unique_keys(evaluated_spellcard_effects)

func add_unique_keys(stack):
	var keys_count = {}
	
	for spellcard_effect in stack:
		if spellcard_effect.name in keys_count:
			keys_count[spellcard_effect.name] += 1
		else:
			keys_count[spellcard_effect.name] = 0
		spellcard_effect.key = "%s_%02d" % [spellcard_effect.name, keys_count[spellcard_effect.name]]
		
	return stack

func evaluate_spellcards(spellcards: Array):
	var stack = []
	for spellcard in spellcards:
		if spellcard == ItemData.EMPTY_ITEM_DATA:
			continue
			
		for spellcard_effect in spellcard.effects:
			var new_spellcard_effect = spellcard_effect.duplicate()
			if stack.size() <= 0:
				stack.append(new_spellcard_effect)
				continue
			else:
				evaluate_spellcard_effect(new_spellcard_effect, stack)
	var result = []
	for effect in stack:
		if effect.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
			result.append(effect)
		elif effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
			result.append(effect)
	return result


func evaluate_spellcard_effect(spellcard_effect, stack):
	## the conditions are based on the top card and the spellcard.
	var is_looping = true
	while is_looping:
		## if the stack is empty, add the spellcard directly
		if stack.size() <= 0:
			stack.append(spellcard_effect)
			is_looping = false
			continue

		var top_effect : SpellCardEffect = stack[stack.size()-1]
		var top_card_sub_type : ItemData.ITEM_SUB_TYPE = top_effect.sub_type
		if spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
			if top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
				## top = projectile + spellcard = projectile
				## cannot combine, append the projectile
				stack.append(spellcard_effect)
				is_looping = false
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
				## top = stats modifier + spellcard = projectile
				## add modifier to spellcard
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				## top = on fire effect modifier + spellcard = projectile
				## add modifier to spellcard
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				## top = on hit effect modifier + spellcard = projectile
				## add modifier to spellcard
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
				## top = mod projectile modifier + spellcard = projectile
				## Add projectile as on_fire effect of the mod_projectile.
				## Note that we don't add the spellcard_effect.
				## Apply top_effect into spellcard_effect
#				top_effect.on_fire_effects.append(spellcard_effect)
				stack.append(spellcard_effect)
				is_looping = false
			else:
				is_looping = false
		elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
			if top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
				## top = projectile + spellcard = stats modifier
				## cannot combine, append the stats modifier
				stack.append(spellcard_effect)
				is_looping = false
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
				## top = stats modifier + spellcard = stats modifier
				## combine modifiers
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				## top = on fire effect modifier + spellcard = stats modifier
				## combine modifiers
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				## top = on hit effect modifier + spellcard = stats modifier
				## combine modifiers
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
				## top = on hit effect modifier + spellcard = mod projectile modifier
				## cannot combine, append
				stack.append(spellcard_effect)
				is_looping = false
			else:
				is_looping = false
		elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
			if top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
				stack.append(spellcard_effect)
				is_looping = false
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
				stack.append(spellcard_effect)
				is_looping = false
		elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
			if top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
				stack.append(spellcard_effect)
				is_looping = false
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
				stack.append(spellcard_effect)
				is_looping = false
		elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
			if top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
				stack.append(spellcard_effect)
				is_looping = false
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				apply_modifier_to_spellcard(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
				stack.append(spellcard_effect)
				is_looping = false
		else:
			is_looping = false
	return stack

func apply_modifier_to_spellcard(spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	if modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
		apply_multiplied_modifier_to_spellcard_effect(spellcard_effect, modifier_card)
	elif modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.ADDITIVE_PROPERTIES_PROJECTILE_MODIFIER:
		apply_additive_modifier_to_spellcard_effect(spellcard_effect, modifier_card)
	
	if modifier_card.get("on_fire_effects"):
		spellcard_effect.on_fire_effects = []
		for spellcard_effect_data in modifier_card.on_fire_effects:
			spellcard_effect.on_fire_effects.append(spellcard_effect_data.duplicate())
	if modifier_card.get("on_hit_effects"):
		spellcard_effect.on_hit_effects = []
		for spellcard_effect_data in modifier_card.on_hit_effects:
			spellcard_effect.on_hit_effects.append(spellcard_effect_data.duplicate())
	return spellcard_effect

func apply_multiplied_modifier_to_spellcard_effect(spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	if modifier_card.get("damage"):
		spellcard_effect.damage *= modifier_card.damage
	if modifier_card.get("damage_shock"):
		spellcard_effect.damage_shock *= modifier_card.damage_shock
	if modifier_card.get("damage_fire"):
		spellcard_effect.damage_fire *= modifier_card.damage_fire
	if modifier_card.get("damage_ice"):
		spellcard_effect.damage_ice *= modifier_card.damage_ice
	if modifier_card.get("damage_poison"):
		spellcard_effect.damage_poison *= modifier_card.damage_poison
	if modifier_card.get("damage_soul"):
		spellcard_effect.damage_soul *= modifier_card.damage_soul
	if modifier_card.get("action_delay"):
		spellcard_effect.action_delay *= modifier_card.action_delay
	if modifier_card.get("num_attacks"):
		spellcard_effect.num_attacks += modifier_card.num_attacks
	if modifier_card.get("spread"):
		spellcard_effect.spread *= modifier_card.spread
	if modifier_card.get("velocity"):
		spellcard_effect.velocity *= modifier_card.velocity
	if modifier_card.get("lifetime"):
		spellcard_effect.lifetime *= modifier_card.lifetime
	if modifier_card.get("radius"):
		spellcard_effect.radius *= modifier_card.radius
	if modifier_card.get("knockback"):
		spellcard_effect.knockback *= modifier_card.knockback
	if modifier_card.get("pierce"):
		spellcard_effect.pierce *= modifier_card.pierce
	if modifier_card.get("bounce"):
		spellcard_effect.bounce *= modifier_card.bounce
	if modifier_card.get("hit_hp"):
		spellcard_effect.hit_hp *= modifier_card.hit_hp
	if modifier_card.get("hit_size"):
		spellcard_effect.hit_size *= modifier_card.hit_size

func apply_additive_modifier_to_spellcard_effect(spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	if modifier_card.get("damage"):
		spellcard_effect.damage += modifier_card.damage
	if modifier_card.get("damage_shock"):
		spellcard_effect.damage_shock += modifier_card.damage_shock
	if modifier_card.get("damage_fire"):
		spellcard_effect.damage_fire += modifier_card.damage_fire
	if modifier_card.get("damage_ice"):
		spellcard_effect.damage_ice += modifier_card.damage_ice
	if modifier_card.get("damage_poison"):
		spellcard_effect.damage_poison += modifier_card.damage_poison
	if modifier_card.get("damage_soul"):
		spellcard_effect.damage_soul += modifier_card.damage_soul
	if modifier_card.get("action_delay"):
		spellcard_effect.action_delay += modifier_card.action_delay
	if modifier_card.get("num_attacks"):
		spellcard_effect.num_attacks += modifier_card.num_attacks
	if modifier_card.get("spread"):
		spellcard_effect.spread += modifier_card.spread
	if modifier_card.get("velocity"):
		spellcard_effect.velocity += modifier_card.velocity
	if modifier_card.get("lifetime"):
		spellcard_effect.lifetime += modifier_card.lifetime
	if modifier_card.get("radius"):
		spellcard_effect.radius += modifier_card.radius
	if modifier_card.get("knockback"):
		spellcard_effect.knockback += modifier_card.knockback
	if modifier_card.get("pierce"):
		spellcard_effect.pierce += modifier_card.pierce
	if modifier_card.get("bounce"):
		spellcard_effect.bounce += modifier_card.bounce
	if modifier_card.get("hit_hp"):
		spellcard_effect.hit_hp += modifier_card.hit_hp
	if modifier_card.get("hit_size"):
		spellcard_effect.hit_size += modifier_card.hit_size



















