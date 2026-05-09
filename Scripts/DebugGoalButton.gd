extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# For a quick test, we can bypass the GoalManager entirely 
	# and just inject money directly to see if the UI updates.
	var debug_reward = 100
	print("Debug: Adding $", debug_reward, " for a fake goal!")
	EconomyManager.add_money(debug_reward)
	
	# IF you want to test the actual GoalManager logic instead:
	# GoalManager.add_progress("connect_first_pipeline", 1)
