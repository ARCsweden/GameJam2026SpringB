extends Control

# --- GODOT'S BUILT-IN DROP CHECKER ---
# This asks: "Is the player allowed to drop this here?"
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# We only accept the drop IF it is ModuleData AND the player has enough money
	if data is ModuleData:
		if EconomyManager.can_afford(data.cost):
			return true
	return false

# --- GODOT'S BUILT-IN DROP EXECUTOR ---
# This runs when the player releases the mouse button over this node
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var module = data as ModuleData
	
	# 1. Take the money!
	if EconomyManager.spend_money(module.cost):
		
		# 2. Spawn the actual 2D game piece
		var new_node = module.packed_scene.instantiate() as Node2D
		
		# 3. Add it to your game board (Replace this with wherever your nodes should go)
		# e.g., get_tree().current_scene.add_child(new_node)
		add_child(new_node)
		
		# 4. Snap it to the mouse position!
		new_node.global_position = get_global_mouse_position()
		
		# 5. --- OUR DYNAMIC GOAL SYSTEM! ---
		# Shout to the GoalManager that we just built something!
		if module.action_tag != "":
			GoalManager.trigger_action(module.action_tag, 1)
