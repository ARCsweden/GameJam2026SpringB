extends Control

@export var module_to_sell: ModuleData

func _on_buy_button_pressed():
	# 1. Ask the global manager if we have enough money
	if EconomyManager.spend_money(module_to_sell.cost):
		print("Bought module!")
		# 2. Tell the game board to spawn the module
		SignalBus.emit_spawn_module(module_to_sell.packed_scene)
	else:
		print("Not enough money!")
		# Maybe play a buzzer sound or flash the text red
