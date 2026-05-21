extends Label

func _ready() -> void:
	# 1. Connect to the global signal so we know when money changes
	EconomyManager.money_changed.connect(_on_money_changed)
	
	# 2. Set the initial text right when the game starts
	update_text(EconomyManager.current_money)

# This function is triggered automatically whenever the signal is emitted
func _on_money_changed(new_amount: int) -> void:
	update_text(new_amount)

# A helper function to format the text nicely
func update_text(amount: int) -> void:
	text = "Money: $" + str(amount)
