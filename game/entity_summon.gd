extends EntityHit

var paths = 3 # number of attacks in attack mode

var target_array = []
var reset_pos = Vector2.ZERO

var sprite_javelin_regular = preload("res://Player/Attacks/Javelin/Textures/javelin_3_new.png")
var sprite_javelin_attack = preload("res://Player/Attacks/Javelin/Textures/javelin_3_new_attack.png")

var attack_speed = 4.0
var change_direction_timer_timeout = 1
var reset_position_timer_timeout = 3

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attack_timer : Timer = $AttackTimer
@onready var change_direction_timer : Timer = $ChangeDirectionTimer
@onready var reset_position_timer : Timer = $ResetPositionTimer
@onready var sound_attack : AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	update_javelin()
	_on_reset_position_timer_timeout()

func update_javelin():
	scale = Vector2(1.0, 1.0) * attack_size
	attack_timer.wait_time = attack_speed

func _process(_delta):
	pass

func _physics_process(delta):
	if target_array.size() > 0:
		position += angle * speed * delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_diff = global_position - player.global_position
		var return_speed = 20
		# come back faster if they are further away
		if abs(distance_diff.x) > 500 or abs(distance_diff.y) > 500:
			return_speed = 100
		
		# remember this runs every tick
		position += player_angle * return_speed * delta
		# +135 degrees to compensate the sprite rotation
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)

func add_paths():
	sound_attack.play()
	emit_signal("remove_from_array", self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target() # target is a Vector2
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]
	process_path()
	
func process_path():
	angle = global_position.direction_to(target)
	change_direction_timer.start()
	var tween = create_tween()
	var new_rotation_degrees = angle.angle() + deg_to_rad(135)
	tween.tween_property(self, "rotation", new_rotation_degrees, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func enable_attack(attack = true):
	if attack:
		collision.call_deferred("set", "disabled", false)
		sprite.texture = sprite_javelin_attack
	else:
		collision.call_deferred("set", "disabled", true)
		sprite.texture = sprite_javelin_regular

## as a summon, the javelin has infinite hits
func enemy_hit(_charge = 1):
	pass

func _on_attack_timer_timeout():
	add_paths()

func _on_change_direction_timer_timeout():
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			sound_attack.play()
			emit_signal("remove_from_array", self)
		else:
			enable_attack(false)
	else:
		change_direction_timer.stop()
		attack_timer.start()
		enable_attack(false)

func _on_reset_position_timer_timeout():
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50

## Override the LifeTimeTimer, javelin does not disappear
func _on_life_time_timer_timeout():
	pass

