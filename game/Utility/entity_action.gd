## A single pass of a spellcard chain.
## Contains Attacks, which the Action uses to create Hits,
## which damage enemies.
extends Node
class_name EntityAction

@export var action_delay : float
@export var reload_time : float
@export var attack_arr : Array[EntityAttack]
@export var attack_params : EntityAttack = EntityAttack.EMPTY_ENTITY_ATTACK # blank object, used to store Attack data and affect attack_arr

## Use the equipment stats to initialize variables
func init(equipment_data: EquipmentData):
	action_delay = equipment_data.action_delay
	reload_time = equipment_data.reload_time
	pass


