extends ItemData
class_name SpellCardData

enum HIT_SPAWN_TYPE {RANDOM_TARGET, PLAYER_DIRECTION}
enum HIT_BEHAVIOR_TYPE {STRAIGHT_LINE, WAVE_PATTERN}
#enum SUMMON_BEHAVIOR_TYPE {}

@export var equipment: ItemData
@export var energy_drain: float
@export var damage: float
@export var damage_shock: float
@export var damage_fire: float
@export var damage_ice: float
@export var damage_poison: float
@export var damage_soul: float
@export var action_delay: float
@export var num_attacks: float # number of projectiles coming out per attack
@export var spread: float
@export var velocity: float
@export var lifetime: float
@export var radius: float
@export var knockback: float
@export var pierce: float
@export var bounce: float
@export var hit_hp: int
@export var hit_size : float
@export var hit_spawn_type: HIT_SPAWN_TYPE
@export var hit_behavior_type: HIT_BEHAVIOR_TYPE
@export var attack_type: String
@export var hit_type : String

@export var on_fire_effect: Array[SpellCardData]
@export var on_travel_effect: Array[SpellCardData]
@export var on_hit_effect: Array[SpellCardData]


static func get_sub_type(s) -> ITEM_SUB_TYPE:
	if s == "PROJECTILE":
		return ItemData.ITEM_SUB_TYPE.PROJECTILE
	elif s == "SUMMON":
		return ItemData.ITEM_SUB_TYPE.SUMMON
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





