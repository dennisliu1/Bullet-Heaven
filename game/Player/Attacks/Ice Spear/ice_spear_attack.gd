extends Node2D

@export var spellcard_data: SpellCardData
var ice_spear = preload("res://Player/Attacks/Ice Spear/ice_spear.tscn")

## attack stats
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1
@onready var icespear_timer = $IceSpearTimer
@onready var icespear_attack_timer = $IceSpearTimer/IceSpearAttackTimer

## runtime variables
var icespear_ammo = 1

func equip_attack():
	icespear_baseammo = spellcard_data

func attack():
	if icespear_level > 0:
		icespear_timer.wait_time = icespear_attackspeed
		if icespear_timer.is_stopped():
			icespear_timer.start()

func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo
	icespear_attack_timer.start()


func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = ice_spear.instantiate()
		icespear_attack.position = position
#		icespear_attack.target = _get_random_target()
#		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			icespear_attack_timer.start()
		else:
			icespear_attack_timer.stop()

