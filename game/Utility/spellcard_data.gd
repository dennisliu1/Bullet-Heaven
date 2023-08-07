extends ItemData
class_name SpellCardData

#@export var sub_type: ITEM_SUB_TYPE

static func get_sub_type(s) -> ITEM_SUB_TYPE:
	if s.nocasecmp_to("PROJECTILE"):
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





