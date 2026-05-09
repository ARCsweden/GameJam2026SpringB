extends Control

@export var goal_store_item_scene: PackedScene

func _ready() -> void:
	pass
	# Listen for when goals activate (this handles chains automatically!)
	GoalManager.goal_activated.connect(_on_goal_activated)
	
	# Race-condition check: Spawn any goals that activated BEFORE this UI loaded
	for goal_id in GoalManager.active_goals.keys():
		var goal_data = GoalManager.goal_definitions[goal_id]
		_spawn_store_button(goal_data)

func _on_goal_activated(goal: GoalData) -> void:
	_spawn_store_button(goal)

func _spawn_store_button(goal: GoalData) -> void:
	# 1. Instantiate the raw node first
	var raw_node = goal_store_item_scene.instantiate()
	
	# 2. Try to cast it to our custom class
	var new_button = raw_node as GoalStoreItemUI
	
	# 3. SAFETY CHECK: Did the cast fail?
	if new_button == null:
		print("CRITICAL ERROR: The scene spawned, but it is NOT a GoalStoreItemUI!")
		print("Make sure class_name GoalStoreItemUI is at the top of its script.")
		raw_node.queue_free() # Clean up the broken node
		return # Stop running this function so the game doesn't crash
		
	# 4. If we made it here, it's safe to use!
	add_child(new_button)
	new_button.setup(goal)
