extends ItemData
class_name SpellCardData

@export var equipment: ItemData
@export var energy_drain: float
@export var damage: float
@export var action_delay: float
@export var num_attacks: float # number of projectiles coming out per attack
@export var spread: float
@export var velocity: float
@export var lifetime: float
@export var radius: float
@export var knockback: float
@export var pierce: float
@export var bounce: float
@export var attack_type: String
@export var hit_type : String

static func get_sub_type(s) -> ITEM_SUB_TYPE:
	if s == "PROJECTILE":
		return ItemData.ITEM_SUB_TYPE.PROJECTILE
	elif s == "ATTACK_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.ATTACK_MODIFIER
	elif s == "MULTICAST":
		return ItemData.ITEM_SUB_TYPE.MULTICAST
	elif s == "ON_FIRE_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER
	elif s == "ON_HIT_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER
	elif s == "PROPERTIES_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER
	elif s == "BEHAVIOR_PROJECTILE_MODIFIER":
		return ItemData.ITEM_SUB_TYPE.BEHAVIOR_PROJECTILE_MODIFIER
	else:
		return ItemData.ITEM_SUB_TYPE.MISC

static func get_attack_type(attack_name):
	if attack_name == "ice_spear":
		return "res://Player/Attacks/Ice Spear/ice_spear_attack.tscn"
	else:
		return null

static func get_hit_type(hit_name):
	if hit_name == "ice_spear":
		return "res://Player/Attacks/Ice Spear/ice_spear.tscn"
	else:
		return null

