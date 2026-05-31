extends Label

@onready var money_change : PackedScene = preload("res://Scenes/Effects/money_change.tscn")

func _ready() -> void:
	# 1. Connect to the global signal so we know when money changes
	EconomyManager.money_changed.connect(_on_money_changed)
	
	# 2. Set the initial text right when the game starts
	update_text(EconomyManager.current_money)

# This function is triggered automatically whenever the signal is emitted
func _on_money_changed(change: int, new_amount: int) -> void:
	var new_node: MoneyChangeFx = money_change.instantiate()
	add_child(new_node)
	new_node.update_money(change)
	new_node.position.x = size.x * 2 / 3
	new_node.position.y = size.y / 2
	update_text(new_amount)

# A helper function to format the text nicely
func update_text(amount: int) -> void:
	text = "Money: $" + str(amount)
