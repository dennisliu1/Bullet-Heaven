## HitBox deals damage to HurtBox when it enters a HurtBox's area.
extends Area2D

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disable_timer = $DisableTimer

## If the attack hits a HurtBox with DisableHitBox, it turns off the attack
## for a short time.
func tempdisable():
	collision.call_deferred("set", "disabled", true)
	disable_timer.start()


func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false)
