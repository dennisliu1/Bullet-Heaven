extends Control

signal next_button_click()
signal reroll_items()

@onready var buy_grid_container:GridContainer = $BuyGridContainer
@onready var inventory_container = $InventoryContainer
@onready var spell_container = $SpellContainer
@onready var gems_container = $GemsContainer
@onready var gems_container_label = $GemsContainer/LabelGems

func add_buy_option(el):
	buy_grid_container.add_child(el)

func remove_buy_option(el):
	buy_grid_container.remove_child(el)

func _on_next_button_click_end():
	emit_signal("next_button_click")

func set_item_visible(index, is_visible):
	get_item(index).visible = is_visible

func get_item(index):
	return buy_grid_container.get_child(index)

func _on_reroll_button_click_end():
	emit_signal("reroll_items")

func get_gems_container_label():
	return gems_container_label
