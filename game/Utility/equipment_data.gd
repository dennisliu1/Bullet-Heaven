extends ItemData
class_name EquipmentData

enum ENERGY_RECHARGE_TYPE {RECHARGE, RELOAD}

## equipment data
@export var energy: float
@export var action_delay: float
@export var recharge_speed_type: ENERGY_RECHARGE_TYPE
@export var recharge_speed: float # energy regained per seond, or time to reload energy
@export var reload_time: float
@export var num_slots : int
@export var spell_slots : Array
@export var spread: float
@export var velocity: int
@export var protection: int


static func get_sub_type(s) -> ITEM_SUB_TYPE:
	if s == "ONE_HANDED":
		return ITEM_SUB_TYPE.ONE_HANDED
	elif s == "TWO_HANDED":
		return ITEM_SUB_TYPE.TWO_HANDED
	elif s == "HAT":
		return ITEM_SUB_TYPE.HAT
	elif s == "CLOTHING":
		return ITEM_SUB_TYPE.CLOTHING
	elif s == "GLOVES":
		return ITEM_SUB_TYPE.GLOVES
	elif s == "SHOES":
		return ITEM_SUB_TYPE.SHOES
	else:
		return ITEM_SUB_TYPE.MISC

static func get_energy_recharge_type(s: String) -> ENERGY_RECHARGE_TYPE:
	if s == "RECHARGE":
		return ENERGY_RECHARGE_TYPE.RECHARGE
	else:
		return ENERGY_RECHARGE_TYPE.RELOAD

