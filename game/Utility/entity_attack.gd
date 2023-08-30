## Attack is an Hit spawner, creating damaging objects to hurt enemies.
## Used inside an Action, which calls Attacks to spawn Hits.
extends Node
class_name EntityAttack

var hit_object
var on_fire_hit_objects: Array
var on_fire_effects: Array

var attack_enabled = true

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var hit_root = get_tree().get_first_node_in_group("hit_root")
@onready var action_delay_timer: Timer = $ActionDelayTimer
@onready var action_reload_timer: Timer = $ActionReloadTimer
var action_count = 0
var single_attack = false

var get_start_position_callable: Callable
var get_direction_callable: Callable
var start_position
var direction_vector

var attack_properties : SpellCardEffect # stores the Attack and Hit properties
var hit_effect : SpellCardEffect

static var EMPTY_ENTITY_ATTACK = EntityAttack.new()

func setup_attack(spellcard_data : SpellCardEffect, get_start_position_arg, get_direction_arg):
#	attack_instance = attack_obj
	attack_properties = spellcard_data
	hit_effect = attack_properties

	var attack_obj_path = SpellCardEffect.get_hit_type(spellcard_data.hit_type)
	hit_object = load(attack_obj_path)
	for spell_effect in spellcard_data.on_fire_effects:
		attack_obj_path = SpellCardEffect.get_hit_type(spell_effect.hit_type)
		hit_object = load(attack_obj_path)
		
		on_fire_hit_objects.append(hit_object)
		on_fire_effects.append(spell_effect)
	
	
	self.get_start_position_callable = get_start_position_arg
	self.get_direction_callable = get_direction_arg
	
	pass

## Call outside to spawn the hits
func do_attack():
	for i in range(on_fire_hit_objects.size()):
		_spawn_hits(on_fire_effects[i], on_fire_effects[i], on_fire_hit_objects[i])
	_spawn_hits(attack_properties, hit_effect, hit_object)
	
func _do_attack_internal():
	do_attack()

func spawn_bullet(spellcard_effect, target_vector, hit_obj):
	if not hit_obj is Resource:
		return
	
	var hit_instance = hit_obj.instantiate()
	
	# TODO replace these player references
	# set hit instance properties
	hit_instance.position = get_start_position()
	hit_instance.target = target_vector
	
	# Set Hit combat properties
	_load_properties_into_hit(hit_instance, spellcard_effect)

	# add the hit instance as a child, put into world
	hit_root.call_deferred("add_child", hit_instance)
#	hit_root.add_child()

func _load_properties_into_hit(hit_instance, spell_effect: SpellCardEffect):
	hit_instance.attack_properties = spell_effect
#	hit_instance.energy_drain = spell_effect.energy_drain
	hit_instance.damage = spell_effect.damage
#	hit_instance.action_delay = spell_effect.action_delay
#	hit_instance.num_attacks = spell_effect.num_attacks
#	hit_instance.spread = spell_effect.spread
	hit_instance.speed = spell_effect.velocity
	hit_instance.lifetime = spell_effect.lifetime
#	hit_instance.radius = spell_effect.radius
	hit_instance.knockback_amount = spell_effect.knockback
	hit_instance.attack_hp = spell_effect.hit_hp
	hit_instance.attack_size = spell_effect.hit_size
	hit_instance.crit_chance = spell_effect.crit_chance
	hit_instance.crit_damage = spell_effect.crit_damage
#	hit_instance.pierce = spell_effect.pierce
#	hit_instance.bounce = spell_effect.bounce
	hit_instance.hit_behaviour_type = spell_effect.hit_behavior_type

	for spellcard in spell_effect.on_hit_effects:
		hit_instance.on_hit_spellcards.append(spellcard)

	return hit_instance

func _spawn_hits(spawn_effect, spellcard_effect, bullet_obj):
	if spawn_effect.hit_spawn_type == SpellCardEffect.HIT_SPAWN_TYPE.SPREAD and spawn_effect.num_attacks > 1:
		var attack_angle = spawn_effect.attack_angle
		var direction_shifted = deg_to_rad(attack_angle) / (spawn_effect.num_attacks-1)
		var left_direction = get_direction().rotated(deg_to_rad(-attack_angle/2))
		var right_direction = get_direction().rotated(deg_to_rad(attack_angle/2))

		for i in range(spawn_effect.num_attacks):
			if i % 2 == 0:
				spawn_bullet(spellcard_effect, add_spread_deviation(get_start_position(), left_direction, spellcard_effect.spread), bullet_obj)
				left_direction = left_direction.rotated(direction_shifted)
			else:
				spawn_bullet(spellcard_effect, add_spread_deviation(get_start_position(), right_direction, spellcard_effect.spread), bullet_obj)
				right_direction = right_direction.rotated(-direction_shifted)
	else:
		var target_vector = add_spread_deviation(get_start_position(), _get_hit_spawn_type(spawn_effect), spellcard_effect.spread)
		spawn_bullet(spellcard_effect, target_vector, bullet_obj)

func _get_hit_spawn_type(spellcard):
	if start_position != null and direction_vector != null: # overridden
		return get_direction()
	elif spellcard.hit_spawn_type == SpellCardEffect.HIT_SPAWN_TYPE.RANDOM_TARGET:
		return player.get_random_target()
	elif spellcard.hit_spawn_type == SpellCardEffect.HIT_SPAWN_TYPE.PLAYER_DIRECTION:
		return get_direction()

func get_direction():
	if direction_vector:
		return direction_vector
	else:
		return get_direction_callable.call()
	
func get_start_position():
	if start_position:
		return start_position
	else:
		return get_start_position_callable.call()

## matches entity_hit


# --- do attacks ---

func setup_effect():
	pass

func set_mod_attack():
	pass

func update_effects():
	if hit_effect.action_delay > 0:
		action_delay_timer.wait_time = hit_effect.action_delay
	if hit_effect.reload_delay > 0:
		action_reload_timer.wait_time = hit_effect.reload_delay

func reset_attack():
	reset_attack_sequence()

func start_single_attack_sequence():
	take_action()


func start_attack_sequence():
	if attack_enabled:
		take_action()
		

func _on_action_delay_timer_timeout():
	take_action()

func take_action():
	_do_attack_internal()
	action_count += 1
	
	if single_attack:
		if action_count < hit_effect.rapid_repeat:
			action_delay_timer.start()
			action_reload_timer.stop()
	else:
		if action_count < hit_effect.rapid_repeat:
			action_delay_timer.start()
			action_reload_timer.stop()
		else:
			action_reload_timer.start()

func _on_action_reload_timer_timeout():
	reset_attack_sequence()

func stop_attack_sequence():
	action_delay_timer.stop()
	action_reload_timer.stop()
	action_count = 0

func reset_attack_sequence():
	stop_attack_sequence()
	start_attack_sequence()

func pause_attack():
	action_delay_timer.paused = true
	action_reload_timer.paused = true

func unpause_attack():
	action_delay_timer.paused = false
	action_reload_timer.paused = false

func enable_attack():
	attack_enabled = true

func disable_attack():
	attack_enabled = false
	stop_attack_sequence()

func add_spread_deviation(start_pos, target_vector, spread):
	var rng_spread = deg_to_rad(randf_range(-1.0, 1.0) * spread)
	var deviated_vector = target_vector.rotated(rng_spread)
	return start_pos + deviated_vector



