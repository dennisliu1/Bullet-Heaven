extends ItemData
class_name SpellCardEffect

enum HIT_SPAWN_TYPE {RANDOM_TARGET, PLAYER_DIRECTION, SPREAD}
enum HIT_BEHAVIOR_TYPE {STRAIGHT_LINE, WAVE_PATTERN, HOMING}
#enum SUMMON_BEHAVIOR_TYPE {FOLLOW_PLAYER, SPIN_AROUND}

@export var energy_drain: float
@export var damage: float
@export var damage_shock: float
@export var damage_fire: float
@export var damage_ice: float
@export var damage_poison: float
@export var damage_soul: float
@export var action_delay: float
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
@export var hit_hp: int
@export var hit_size : float
@export var hit_spawn_type: HIT_SPAWN_TYPE
@export var hit_behavior_type: HIT_BEHAVIOR_TYPE
@export var attack_type: String
@export var hit_type : String

@export var on_fire_effect: Array[SpellCardEffect]
@export var on_travel_effect: Array[SpellCardEffect]
@export var on_hit_effect: Array[SpellCardEffect]

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

static func get_hit_spawn_type(hit_spawn_type_name):
	if hit_spawn_type_name == "RANDOM_TARGET":
		return HIT_SPAWN_TYPE.RANDOM_TARGET
	elif hit_spawn_type_name == "PLAYER_DIRECTION":
		return HIT_SPAWN_TYPE.PLAYER_DIRECTION
	elif hit_spawn_type_name == "SPREAD":
		return HIT_SPAWN_TYPE.SPREAD
	else:
		return HIT_SPAWN_TYPE.RANDOM_TARGET

static func get_hit_behavior_type(hit_spawn_behavior_type):
	if hit_spawn_behavior_type == "STRAIGHT_LINE":
		return HIT_BEHAVIOR_TYPE.STRAIGHT_LINE
	elif hit_spawn_behavior_type == "WAVE_PATTERN":
		return HIT_BEHAVIOR_TYPE.WAVE_PATTERN
	elif hit_spawn_behavior_type == "HOMING":
		return HIT_BEHAVIOR_TYPE.HOMING
	else:
		return HIT_BEHAVIOR_TYPE.STRAIGHT_LINE

