extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")

@export var enemy_detect_area : Area2D

var entity_hit: EntityHit # stores the hit properties
@export var attack_hp = 1


@export var speed = 100
@export var damage = 5
@export var knockback_amount = 100


@export var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

signal remove_from_array(object)

## Called when the node enters the scene tree for the first time.
func _ready():
#	speed = entity_hit.hit_properties.velocity
#	damage = entity_hit.hit_properties.damage
#	knockback_amount = entity_hit.hit_properties.knockback
	
	angle = global_position.direction_to(target)

	# the ice spear is current 45 degrees, so we compensate by adding 135 degrees
	# this way, the ice spear is equal to Vector(1, 0)
	# and faces right
	rotation = angle.angle() + deg_to_rad(135)
	
	# a small animation where the ice spear starts off small and grows into
	# its full size.
	# Tween interpolates between two states, shifting from oen to the other.
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += angle * speed * delta

## Called by HurtBox, when it hits an enemy.
## When the ice spear hits the enemy, remove this projectile.
func enemy_hit(charge = 1):
	attack_hp -= charge
	if attack_hp <= 0:
		_delete_self()

func _delete_self():
	emit_signal("remove_from_array", self)
	queue_free()

func _on_life_time_timer_timeout():
	_delete_self()
