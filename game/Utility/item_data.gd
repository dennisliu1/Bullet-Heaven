extends Resource
class_name ItemData

enum ITEM_TYPE {OTHER, EQUIPMENT, SPELLCARD, CONSUMABLE}
enum ITEM_SUB_TYPE {
	MISC, ONE_HANDED, TWO_HANDED, HAT, CLOTHING, GLOVES, SHOES,
	PROJECTILE, ATTACK_MODIFIER, MULTICAST,
	ON_FIRE_PROJECTILE_MODIFIER, ON_HIT_PROJECTILE_MODIFIER,
	PROPERTIES_PROJECTILE_MODIFIER, BEHAVIOR_PROJECTILE_MODIFIER}

static var EMPTY_ITEM_DATA = ItemData.new()

@export var name: String = ""
@export var texture: Texture
@export var type: ITEM_TYPE
@export var sub_type: ITEM_SUB_TYPE
@export var key : String

static func get_type(s : String) -> ITEM_TYPE:
	if s == "EQUIPMENT":
		return ITEM_TYPE.EQUIPMENT
	elif s == "SPELLCARD":
		return ITEM_TYPE.SPELLCARD
	elif s == "CONSUMABLE":
		return ITEM_TYPE.CONSUMABLE
	else:
		return ITEM_TYPE.OTHER


static func get_sub_type(s) -> ITEM_SUB_TYPE:
	if s.nocasecmp_to("ONE_HANDED"):
		return ITEM_SUB_TYPE.ONE_HANDED
	elif s.nocasecmp_to("TWO_HANDED"):
		return ITEM_SUB_TYPE.TWO_HANDED
	elif s.nocasecmp_to("HAT"):
		return ITEM_SUB_TYPE.HAT
	elif s.nocasecmp_to("CLOTHING"):
		return ITEM_SUB_TYPE.CLOTHING
	elif s.nocasecmp_to("GLOVES"):
		return ITEM_SUB_TYPE.GLOVES
	elif s.nocasecmp_to("SHOES"):
		return ITEM_SUB_TYPE.SHOES
	elif s.nocasecmp_to("PROJECTILE"):
		return ITEM_SUB_TYPE.PROJECTILE
	elif s.nocasecmp_to("ATTACK_MODIFIER"):
		return ITEM_SUB_TYPE.ATTACK_MODIFIER
	elif s.nocasecmp_to("MULTICAST"):
		return ITEM_SUB_TYPE.MULTICAST
	elif s.nocasecmp_to("ON_FIRE_PROJECTILE_MODIFIER"):
		return ITEM_SUB_TYPE.ON_FIRE_PROJECTILE_MODIFIER
	elif s.nocasecmp_to("ON_HIT_PROJECTILE_MODIFIER"):
		return ITEM_SUB_TYPE.ON_HIT_PROJECTILE_MODIFIER
	elif s.nocasecmp_to("PROPERTIES_PROJECTILE_MODIFIER"):
		return ITEM_SUB_TYPE.PROPERTIES_PROJECTILE_MODIFIER
	elif s.nocasecmp_to("BEHAVIOR_PROJECTILE_MODIFIER"):
		return ITEM_SUB_TYPE.BEHAVIOR_PROJECTILE_MODIFIER
	else:
		return ITEM_SUB_TYPE.MISC
