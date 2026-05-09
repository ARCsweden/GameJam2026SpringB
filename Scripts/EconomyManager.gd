extends Node

# --- Signals ---
signal money_changed(new_amount: int)
signal goal_completed(goal_id: String, reward: int)

# --- VARIABLES ---
var current_money: int = 0

# --- RESOURCE FUNCTIONS ---
func initialize_game(starting_money: int):
		current_money = starting_money
		money_changed.emit(current_money)
		
func add_money(amount: int) -> void:
	if amount > 0:
		current_money += amount
		money_changed.emit(current_money)
			
func can_afford(cost: int) -> bool:
		return current_money >= cost
		
func spend_money(cost: int) -> bool:
		if can_afford(cost):
			current_money -= cost
			money_changed.emit(current_money)
			return true
		return false
	
