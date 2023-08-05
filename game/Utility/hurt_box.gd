## A HurtBox for game agents.
## When an attack enters the HurtBox, it damages the agent.
## Handles damage, knockback, and any attack properties like bounce and pierce.
extends Area2D

@export_enum("DisableHitBox", "Cooldown", "HitOnce") var HurtBoxType = 0

const DEFAULT_KNOCKBACK = 1
const DEFAULT_ANGLE = Vector2.ZERO

@onready var collision = $CollisionShape2D
@onready var disable_timer = $DisableTimer

signal hurt(damage, angle, knockback)

# Used for HitOnce, tracks what attacks have already hit the HurtBox.
var hit_once_array = []

## When a HitBox enters the HurtBox, it causes damage and updates the attack
## properties.
## Can behave differently based on the type of hit recovery.
func _on_area_entered(area):
	if area.is_in_group("attack") and not area.get("damage") == null:
		match HurtBoxType:
			0: # DisableHitBox
				_disable_hit_box(area)
			1: # Cooldown
				_on_hit_cooldown_recovery()
			2: # HitOnce
				# Exit early if the attack already hit once
				if _on_hit_once_recovery(area):
					return
		
		_send_hurt_signal(area)
		_update_enemy_hit_count(area)

## Re-enable the HurtBox after the timeout.
func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false)

## In Cooldown mode, the HurtBox is disabled for a duration.
## Re-enable it after the timer is done.
func _on_hit_cooldown_recovery():
	collision.call_deferred("set", "disabled", true)
	disable_timer.start()

## In HitOnce mode, the HurtBox only works once per enemy attack.
## If the attack de-spawns, we should remove it from the list.
func _on_hit_once_recovery(area):
	if not hit_once_array.has(area):
		hit_once_array.append(area)
		if area.has_signal("remove_from_array"):
			if not area.is_connected("remove_from_array", Callable(self, "remove_from_list")):
				area.connect("remove_from_array", Callable(self, "remove_from_list"))
		return false
	else:
		return true

func _send_hurt_signal(area : Area2D):
	var damage = area.damage
	var angle = DEFAULT_ANGLE
	var knockback = DEFAULT_KNOCKBACK

	if not area.get("angle") == null:
		angle = area.angle
	if not area.get("knockback_amount") == null:
		knockback = area.knockback_amount
	
	emit_signal("hurt", damage, angle, knockback)

## Some attacks have special properties related to how many targets they have
## hit, such as pierce, bounce mechanics.
## Call the attack callback so it knows it hit an agent.
func _update_enemy_hit_count(area : Area2D):
	if area.has_method("enemy_hit"):
		area.enemy_hit(1)

## Connected with _on_hit_once_recovery(),
## removes the attack if it de-spawns or otherwise going to be hit again.
func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

## The DisableHitBox mode disables the attack's HitBOx for a duration.
## Forces all attacks to the agent to be disabled for some time.
func _disable_hit_box(area):
	if area.has_method("tempdisable"):
		area.tempdisable()
