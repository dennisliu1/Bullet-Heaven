extends CharacterBody2D

# player game variables
var movement_speed = 80.0 # 80 pixels per second moved

# player base properties




# references
@onready var sprite = $Sprite2D



func _physics_process(_delta): # 60 FPS
	movement()

func movement():
	# get_action_strength return 0 or 1, if it is pressed = 1
	# so left = 1 - 0 = 1
	var x_move = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_move = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var move_direction = Vector2(x_move, y_move)

	# change the sprite direction.
	if move_direction.x > 0:
		sprite.flip_h = true
	elif move_direction.x < 0:
		sprite.flip_h = false

	# normalize to get the vector direction, handles diagonal length properly
	# Multiply by delta to update based on current frame rate.
	# move_and_slide already multiplies by delta, so we don't need to use it in velocity.
	velocity = move_direction.normalized() * movement_speed
	move_and_slide()
