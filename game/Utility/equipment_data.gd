extends ItemData
class_name EquipmentData

@export var num_slots : int
@export var spell_slots : Array

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
	else:
		return ITEM_SUB_TYPE.MISC


