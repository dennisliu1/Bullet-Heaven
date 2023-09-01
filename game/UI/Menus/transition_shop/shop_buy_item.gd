extends Control

var index: int
@export var item: SpellCardData
@export var price: int
@onready var item_slot = $ItemSlot
@onready var buy_button:Button = $BuyButton
@onready var lock_button:Button = $LockButton

signal buy_item(index, item, price)
signal lock_item(index, item)
signal unlock_item(index, item)

var lock_normal_style:StyleBoxFlat = StyleBoxFlat.new()
var lock_hover_style:StyleBoxFlat = StyleBoxFlat.new()
var lock = false

func _ready():
	lock_normal_style.bg_color = Color(0.01176470611244, 0.4745098054409, 0.48627451062202)
	lock_hover_style.bg_color = Color(0.01942980661988, 0.63553732633591, 0.65090048313141)

func set_item(index, item, price):
	self.index = index
	self.item = item
	self.price = price
	item_slot.display_item(self.item)

func connect_item(node, buy_item_function_name, lock_item_function_name, unlock_item_function_name):
	connect("buy_item", Callable(node, buy_item_function_name))
	connect("lock_item", Callable(node, lock_item_function_name))
	connect("unlock_item", Callable(node, unlock_item_function_name))

func _on_buy_button_click_end():
	emit_signal("buy_item", index, item, price)
	item_slot.visible = false
	buy_button.visible = false
	lock_button.visible = false


func _on_lock_button_click_end():
	if lock:
		emit_signal("unlock_item", index, item)
		lock_button.remove_theme_stylebox_override("normal")
		lock_button.remove_theme_stylebox_override("hover")
		lock = false
	else:
		emit_signal("lock_item", index, item)
		lock_button.add_theme_stylebox_override("normal", lock_normal_style)
		lock_button.add_theme_stylebox_override("hover", lock_hover_style)
		lock = true





