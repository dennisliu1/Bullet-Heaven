extends ItemData
class_name SpellCardEffect

enum HIT_SPAWN_TYPE {NONE, SPREAD}
enum HIT_FACING_TYPE {NONE, RANDOM_TARGET, PLAYER_DIRECTION}
enum HIT_MOVEMENT_TYPE {NONE, STRAIGHT_LINE, PING_PONG_PATH}
enum HIT_BEHAVIOUR_TYPE {NONE, HOMING, ACCELERATING_HOMING, DECELERATING_HOMING}
#enum SUMMON_BEHAVIOR_TYPE {FOLLOW_PLAYER, SPIN_AROUND}

# if the effect is a mod_projectile_modifier,
# we need to know how many effects it is connected to.
@export var required_effects: int
@export var energy_drain: float
@export var damage: float
@export var damage_shock: float
@export var damage_fire: float
@export var damage_ice: float
@export var damage_poison: float
@export var damage_soul: float
@export var action_delay: float
@export var rapid_repeat: float # number of attacks in a row

@export var reload_delay: float
@export var num_attacks: float # number of projectiles coming out per attack

## The angle which the hits come out as, if num_attacks is more than one.
## This is different from spread, which adds deviation from the ideal direction.
@export var attack_angle: float
## Deviation from the ideal direction vector.
@export var spread: float
@export var velocity: float
@export var lifetime: float
@export var radius: float
@export var knockback: float
@export var pierce: float
@export var bounce: float
@export var crit_chance: float
@export var crit_damage: float
@export var hit_hp: int
@export var hit_size : float
@export var hit_spawn_type: HIT_SPAWN_TYPE
@export var hit_facing_type: HIT_FACING_TYPE
@export var hit_movement_type: HIT_MOVEMENT_TYPE
@export var hit_behaviour_type: HIT_BEHAVIOUR_TYPE
@export var attack_type: String
@export var hit_type : String
@export var multicast: bool

@export var on_fire_effects: Array[SpellCardEffect]
@export var on_travel_effects: Array[SpellCardEffect] # TODO
@export var on_hit_effects: Array[SpellCardEffect]



static func get_sub_type(s) -> ITEM_SUB_TYPE:
	if s == "PROJECTILE":
		return ItemData.ITEM_SUB_TYPE.PROJECTILE
	elif s == "SUMMON":
		return ItemData.ITEM_SUB_TYPE.SUMMON
	elif s == "ATTACK_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.ATTACK_MODIFIER
	elif s == "MOD_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER
	elif s == "MULTICAST":
		return ItemData.ITEM_SUB_TYPE.MULTICAST
	elif s == "ON_FIRE_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER
	elif s == "ON_HIT_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER
	elif s == "PROPERTIES_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER
	elif s == "ADDITIVE_PROPERTIES_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.ADDITIVE_PROPERTIES_PROJECTILE_MODIFIER
	elif s == "BEHAVIOR_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.BEHAVIOR_PROJECTILE_MODIFIER
	else:
		return ItemData.ITEM_SUB_TYPE.MISC

static func get_attack_type(attack_name):
	if attack_name == "ice_spear":
		return "res://Player/Attacks/Ice Spear/ice_spear_attack.tscn"
	elif attack_name == "tornado":
		return "res://Player/Attacks/Tornado/tornado_attack.tscn"
	elif attack_name == "javelin":
		return "res://Player/Attacks/Javelin/javelin_attack.tscn"
	elif attack_name == "arrow":
		return "res://Player/Attacks/Arrow/arrow_attack.tscn"
	else:
		return null

static func get_hit_type(hit_name):
	if hit_name == "ice_spear":
		return "res://Player/Attacks/Ice Spear/ice_spear.tscn"
	elif hit_name == "tornado":
		return "res://Player/Attacks/Tornado/tornado.tscn"
	elif hit_name == "javelin":
		return "res://Player/Attacks/Javelin/javelin.tscn"
	elif hit_name == "arrow":
		return "res://Player/Attacks/Arrow/arrow.tscn"
	else:
		return null

static func get_hit_spawn_type(hit_spawn_type_name):
	if hit_spawn_type_name == "NONE":
		return HIT_SPAWN_TYPE.NONE
	elif hit_spawn_type_name == "SPREAD":
		return HIT_SPAWN_TYPE.SPREAD
	else:
		return HIT_SPAWN_TYPE.NONE

static func get_hit_facing_type(hit_facing_type_name):
	if hit_facing_type_name == "RANDOM_TARGET":
		return HIT_FACING_TYPE.RANDOM_TARGET
	elif hit_facing_type_name == "PLAYER_DIRECTION":
		return HIT_FACING_TYPE.PLAYER_DIRECTION
	else:
		return HIT_FACING_TYPE.RANDOM_TARGET

static func get_hit_movement_type(hit_spawn_movement_type):
	if hit_spawn_movement_type == "STRAIGHT_LINE":
		return HIT_MOVEMENT_TYPE.STRAIGHT_LINE
	elif hit_spawn_movement_type == "PING_PONG_PATH":
		return HIT_MOVEMENT_TYPE.PING_PONG_PATH
	else:
		return HIT_MOVEMENT_TYPE.STRAIGHT_LINE

static func get_hit_behaviour_type(hit_spawn_behaviour_type):
	if hit_spawn_behaviour_type == "NONE":
		return HIT_BEHAVIOUR_TYPE.NONE
	elif hit_spawn_behaviour_type == "HOMING":
		return HIT_BEHAVIOUR_TYPE.HOMING
	elif hit_spawn_behaviour_type == "ACCELERATING_HOMING":
		return HIT_BEHAVIOUR_TYPE.ACCELERATING_HOMING
	elif hit_spawn_behaviour_type == "DECELERATING_HOMING":
		return HIT_BEHAVIOUR_TYPE.DECELERATING_HOMING
	else:
		return HIT_BEHAVIOUR_TYPE.NONE

static func evaluate_spellcards(spellcards: Array):
	var evaluated_spellcard_effects = evaluate_spellcard_data(spellcards)
	return add_unique_keys(evaluated_spellcard_effects)

static func add_unique_keys(stack):
	var keys_count = {}
	for spellcard_effect in stack:
		if spellcard_effect.name in keys_count:
			keys_count[spellcard_effect.name] += 1
		else:
			keys_count[spellcard_effect.name] = 0
		spellcard_effect.key = "%s_%02d" % [spellcard_effect.name, keys_count[spellcard_effect.name]]
	return stack

static func evaluate_spellcard_data(spellcards: Array):
	var stack: Array[SpellCardEffect] = []
	for spellcard in spellcards:
		# Ignore empty items
		if spellcard == ItemData.EMPTY_ITEM_DATA:
			continue
		
		# spellcards can have multiple effects, so iterate through each one.
		evaluate_spellcard_effects(spellcard.effects, stack)
	# remove non-rendering effects
	var x = 0
	while x < stack.size():
		if stack[x].sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE or stack[x].sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
			x += 1
		else:
			stack.remove_at(x)
	return stack

static func evaluate_spellcard_effects(spellcard_effects: Array, stack: Array[SpellCardEffect]):
	for spellcard_effect in spellcard_effects:
		var new_spellcard_effect = spellcard_effect.duplicate()
		evaluate_spellcard_effect(new_spellcard_effect, stack)

static func evaluate_spellcard_effect(spellcard_effect: SpellCardEffect, stack: Array[SpellCardEffect]):
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
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				## top = on fire effect modifier + spellcard = stats modifier
				## combine modifiers
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				## top = on hit effect modifier + spellcard = stats modifier
				## combine modifiers
				combine_modifiers(spellcard_effect, top_effect)
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
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
				stack.append(spellcard_effect)
				is_looping = false
		elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
			if top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
				stack.append(spellcard_effect)
				is_looping = false
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
				stack.append(spellcard_effect)
				is_looping = false
		elif spellcard_effect.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
			if top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROJECTILE:
				stack.append(spellcard_effect)
				is_looping = false
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
				combine_modifiers(spellcard_effect, top_effect)
				stack.pop_back()
			elif top_card_sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
				stack.append(spellcard_effect)
				is_looping = false
		else:
			is_looping = false


static func apply_modifier_to_spellcard(spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	if modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
		apply_multiplied_modifier_to_spellcard_effect(spellcard_effect, modifier_card)
	elif modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.MOD_PROJECTILE_MODIFIER:
		apply_multiplied_modifier_to_spellcard_effect(spellcard_effect, modifier_card)
	elif modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
		apply_multiplied_modifier_to_spellcard_effect(spellcard_effect, modifier_card)
	elif modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
		apply_multiplied_modifier_to_spellcard_effect(spellcard_effect, modifier_card)
	elif modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.ADDITIVE_PROPERTIES_PROJECTILE_MODIFIER:
		apply_additive_modifier_to_spellcard_effect(spellcard_effect, modifier_card)
	
	if modifier_card.get("hit_spawn_type"):
		spellcard_effect.hit_spawn_type = modifier_card.hit_spawn_type
	if modifier_card.get("hit_facing_type"):
		spellcard_effect.hit_facing_type = modifier_card.hit_facing_type
	if modifier_card.get("hit_movement_type"):
		spellcard_effect.hit_movement_type = modifier_card.hit_movement_type
	if modifier_card.get("hit_behaviour_type"):
		spellcard_effect.hit_behaviour_type = modifier_card.hit_behaviour_type
	
	if modifier_card.get("on_fire_effects"):
		spellcard_effect.on_fire_effects = []
		for spellcard_effect_data in modifier_card.on_fire_effects:
			spellcard_effect.on_fire_effects.append(spellcard_effect_data.duplicate())
	if modifier_card.get("on_hit_effects"):
		spellcard_effect.on_hit_effects = []
		for spellcard_effect_data in modifier_card.on_hit_effects:
			spellcard_effect.on_hit_effects.append(spellcard_effect_data.duplicate())
	return spellcard_effect

static func combine_modifiers(spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	if modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER:
		combine_multiplied_modifier_spellcard_effects(spellcard_effect, modifier_card)
	elif modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER:
		combine_multiplied_modifier_spellcard_effects(spellcard_effect, modifier_card)
	elif modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER:
		combine_multiplied_modifier_spellcard_effects(spellcard_effect, modifier_card)
	elif modifier_card.sub_type == ItemData.ITEM_SUB_TYPE.ADDITIVE_PROPERTIES_PROJECTILE_MODIFIER:
		apply_additive_modifier_to_spellcard_effect(spellcard_effect, modifier_card)
	
	if modifier_card.get("hit_spawn_type"):
		spellcard_effect.hit_spawn_type = modifier_card.hit_spawn_type
	if modifier_card.get("hit_facing_type"):
		spellcard_effect.hit_facing_type = modifier_card.hit_facing_type
	if modifier_card.get("hit_movement_type"):
		spellcard_effect.hit_movement_type = modifier_card.hit_movement_type
	if modifier_card.get("hit_behaviour_type"):
		spellcard_effect.hit_behaviour_type = modifier_card.hit_behaviour_type
	
	if modifier_card.get("on_fire_effects"):
		spellcard_effect.on_fire_effects = []
		for spellcard_effect_data in modifier_card.on_fire_effects:
			spellcard_effect.on_fire_effects.append(spellcard_effect_data.duplicate())
	if modifier_card.get("on_hit_effects"):
		spellcard_effect.on_hit_effects = []
		for spellcard_effect_data in modifier_card.on_hit_effects:
			spellcard_effect.on_hit_effects.append(spellcard_effect_data.duplicate())
	return spellcard_effect

static func apply_multiplied_modifier_to_spellcard_effect(spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	multiply_modifier_effect("damage", spellcard_effect, modifier_card)
	multiply_modifier_effect("damage_shock", spellcard_effect, modifier_card)
	multiply_modifier_effect("damage_fire", spellcard_effect, modifier_card)
	multiply_modifier_effect("damage_ice", spellcard_effect, modifier_card)
	multiply_modifier_effect("damage_poison", spellcard_effect, modifier_card)
	multiply_modifier_effect("damage_soul", spellcard_effect, modifier_card)
	multiply_modifier_effect("rapid_repeat", spellcard_effect, modifier_card)
	multiply_modifier_effect("reload_delay", spellcard_effect, modifier_card)
	multiply_modifier_effect("action_delay", spellcard_effect, modifier_card)
	multiply_modifier_effect("num_attacks", spellcard_effect, modifier_card)
	multiply_modifier_effect("spread", spellcard_effect, modifier_card)
	multiply_modifier_effect("velocity", spellcard_effect, modifier_card)
	multiply_modifier_effect("lifetime", spellcard_effect, modifier_card)
	multiply_modifier_effect("radius", spellcard_effect, modifier_card)
	multiply_modifier_effect("knockback", spellcard_effect, modifier_card)
	multiply_modifier_effect("pierce", spellcard_effect, modifier_card)
	multiply_modifier_effect("bounce", spellcard_effect, modifier_card)
	multiply_modifier_effect("crit_chance", spellcard_effect, modifier_card)
	multiply_modifier_effect("crit_damage", spellcard_effect, modifier_card)
	multiply_modifier_effect("hit_hp", spellcard_effect, modifier_card)
	multiply_modifier_effect("hit_size", spellcard_effect, modifier_card)
	multiply_modifier_effect("attack_angle", spellcard_effect, modifier_card)

static func combine_multiplied_modifier_spellcard_effects(spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	multiply_or_set_modifier_effect("damage", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("damage_shock", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("damage_fire", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("damage_ice", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("damage_poison", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("damage_soul", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("rapid_repeat", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("reload_delay", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("action_delay", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("num_attacks", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("spread", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("velocity", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("lifetime", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("radius", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("knockback", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("pierce", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("bounce", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("hit_hp", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("hit_size", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("attack_angle", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("crit_chance", spellcard_effect, modifier_card)
	multiply_or_set_modifier_effect("crit_damage", spellcard_effect, modifier_card)

static func apply_additive_modifier_to_spellcard_effect(spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
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
	if modifier_card.get("crit_chance"):
		spellcard_effect.crit_chance += modifier_card.crit_chance
	if modifier_card.get("crit_damage"):
		spellcard_effect.crit_damage += modifier_card.crit_damage

static func update_effect(target_effect, instance_effect):
	target_effect.required_effects = instance_effect.required_effects
	target_effect.energy_drain = instance_effect.energy_drain
	target_effect.damage = instance_effect.damage
	target_effect.reload_delay = instance_effect.reload_delay
	target_effect.action_delay = instance_effect.action_delay
	target_effect.rapid_repeat = instance_effect.rapid_repeat
	target_effect.num_attacks = instance_effect.num_attacks
	target_effect.attack_angle = instance_effect.attack_angle
	target_effect.spread = instance_effect.spread
	target_effect.velocity = instance_effect.velocity
	target_effect.lifetime = instance_effect.lifetime
	target_effect.radius = instance_effect.radius
	target_effect.knockback = instance_effect.knockback
	target_effect.pierce = instance_effect.pierce
	target_effect.bounce = instance_effect.bounce
	target_effect.hit_hp = instance_effect.hit_hp
	target_effect.hit_size = instance_effect.hit_size
	target_effect.crit_chance = instance_effect.crit_chance
	target_effect.crit_damage = instance_effect.crit_damage
	target_effect.hit_movement_type = instance_effect.hit_movement_type
	target_effect.hit_behaviour_type = instance_effect.hit_behaviour_type
	
	target_effect.on_hit_effects.clear()
	for on_hit_effect in instance_effect.on_hit_effects:
		target_effect.on_hit_effects.append(on_hit_effect)

static func multiply_or_set_modifier_effect(variable, spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	if modifier_card.get(variable):
		if spellcard_effect.get(variable):
			spellcard_effect[variable] *= modifier_card[variable]
		else:
			spellcard_effect[variable] = modifier_card[variable]

static func multiply_modifier_effect(variable, spellcard_effect: SpellCardEffect, modifier_card: SpellCardEffect):
	if modifier_card.get(variable):
		spellcard_effect[variable] *= modifier_card[variable]











