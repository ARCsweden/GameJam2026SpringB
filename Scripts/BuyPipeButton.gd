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
		print("Successfully bought: ", module_to_buy.module_name)
		
		# Here is where you would tell your game board to let the player 
		# place the module. For example:
		# BuildManager.start_placing(module_to_buy.packed_scene)
		
	else:
		print("Not enough money to buy: ", module_to_buy.module_name)
