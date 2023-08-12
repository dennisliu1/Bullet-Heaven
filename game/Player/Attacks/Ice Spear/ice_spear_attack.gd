extends Node2D

var hit_object = preload("res://Player/Attacks/Ice Spear/ice_spear.tscn")

#@export var spellcard_data: SpellCardData
@export var entity_attack : EntityAttack
@export var enemy_detect_area : Area2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")


#@onready var action_delay_timer = $ActionDelayTimer
#var action_delay: float

func spawn_bullet():
	var hit_instance = hit_object.instantiate()
	
	# TODO replace these player references
	# set hit instance properties
	hit_instance.position = player.position
#	hit_instance.enemy_detect_area = enemy_detect_area
	hit_instance.target = player.get_random_target()

	# Set Hit combat properties
	

	# add the hit instance as a child, put into world
	add_child(hit_instance)

func do_attack():
	spawn_bullet()
































#var ice_spear = preload("res://Player/Attacks/Ice Spear/ice_spear.tscn")
#
### attack stats
#var icespear_baseammo = 1
#var icespear_attackspeed = 1.5
#var icespear_level = 1
#
#
#
#@onready var icespear_timer = $IceSpearTimer
#@onready var icespear_attack_timer = $IceSpearTimer/IceSpearAttackTimer
#
### runtime variables
#var icespear_ammo = 1
#
#func equip_attack():
#	icespear_baseammo = spellcard_data
#
#func attack():
#	if icespear_level > 0:
#		icespear_timer.wait_time = icespear_attackspeed
#		if icespear_timer.is_stopped():
#			icespear_timer.start()
#
#func _on_ice_spear_timer_timeout():
#	icespear_ammo += icespear_baseammo
#	icespear_attack_timer.start()
#
#
#func _on_ice_spear_attack_timer_timeout():
#	if icespear_ammo > 0:
#		pass

