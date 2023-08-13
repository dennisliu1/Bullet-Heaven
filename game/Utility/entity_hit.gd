extends Area2D
class_name EntityHit

#var hit_object : Node
#var hit_properties: SpellCardData
#var hit_behavior : String
#
#static var EMPTY_ENTITY_HIT = EntityHit.new()

@onready var player = get_tree().get_first_node_in_group("player")
@onready var life_time_timer = $LifeTimeTimer

@export var enemy_detect_area : Area2D

var entity_hit: EntityHit # stores the hit properties


# Hit properties
@export var speed : float = 100.0
@export var damage = 5
@export var knockback_amount = 100
@export var attack_size = 1.0
@export var attack_hp = 1
@export var lifetime : int

## Hit internal properties
var target = Vector2.ZERO
var angle = Vector2.ZERO

signal remove_from_array(object)

## Called when the node enters the scene tree for the first time.
func _ready():
	life_time_timer.wait_time = lifetime
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














