extends ColorRect

@onready var label_name = $LabelName
@onready var label_description = $LabelDescription
@onready var label_level = $LabelLevel
@onready var item_icon = $ColorRect/ItemIcon

var mouse_over = false
var item_type = "spell"
var item = null


@onready var player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready():
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	
	if item_type == "spell":
		var spellcards_data = Global.get_spellcards_data()[item.dict_key]
		label_name.text = spellcards_data["name"]
		label_description.text = spellcards_data["description"]
#		label_level.text = spellcards_data["level"] # TODO: should spells get levels?
		item_icon.texture = spellcards_data.texture


func _input(event):
	if event is InputEventMouseButton and event.is_pressed(): # event.is_action("click"):
		if mouse_over:
			emit_signal("selected_upgrade", item)

func _on_mouse_entered():
	mouse_over = true


func _on_mouse_exited():
	mouse_over = false
