extends Panel

@onready var inventory_container = $InventoryContainer
@export var spellcard_inventory_data : InventoryData
@onready var spell_container = $SpellContainer

@onready var player = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	spellcard_inventory_data.items_changed.connect(_on_spellcard_changed)

func _on_spellcard_changed(_changed_spellcards):
	# changed_spellcards = [modified-card-index]
	refresh_spell_effects_data()

## Compiles the spell cards into spell effects, ready to send to spell container
func refresh_spell_effects_data():
	var instance_stack = SpellCardEffect.evaluate_spellcards(spellcard_inventory_data.items as Array[SpellCardData])
	player.sync_bulk_spellcard_effects(instance_stack)



