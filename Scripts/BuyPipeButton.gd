extends Button

# This exposes a slot in the Inspector where we can drag our .tres file
@export var module_to_buy: ModuleData

func _ready() -> void:
	# Connect the button's built-in pressed signal to our custom function
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Check if we assigned a module in the inspector to prevent errors
	if module_to_buy == null:
		print("Error: No module assigned to this button!")
		return
		
	# Ask the EconomyManager to spend the money
	if EconomyManager.spend_money(module_to_buy.cost):
		if module_to_buy.action_tag != "":
			GoalManager.trigger_action(module_to_buy.action_tag,1)
		#if module_to_buy.goal_id_to_trigger != "":
		#	GoalManager.add_progress(module_to_buy.goal_id_to_trigger,1)
		#	print("Updated Goal: ",module_to_buy.goal_id_to_trigger)
		print("Successfully bought: ", module_to_buy.module_name)
		
		
		# Here is where you would tell your game board to let the player 
		# place the module. For example:
		# BuildManager.start_placing(module_to_buy.packed_scene)
		
	else:
		print("Not enough money to buy: ", module_to_buy.module_name)
