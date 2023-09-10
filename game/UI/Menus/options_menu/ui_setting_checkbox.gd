extends HBoxContainer

@export var title = ""
@onready var label = $Label

signal toggled(is_button_pressed)

func _ready():
	label.text = title

func _on_check_box_toggled(button_pressed):
	emit_signal("toggled", button_pressed)

func set_title(value: String):
	title = value
	await self.is_node_ready()
	label.text = title
