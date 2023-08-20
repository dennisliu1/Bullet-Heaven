extends Control

@export var stage_name: String = "Stage Name"

# Called when the node enters the scene tree for the first time.
func _ready():
	$StageName.text = stage_name

