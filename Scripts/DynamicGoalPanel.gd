extends VBoxContainer

# 1. Expose a slot in the Inspector so we can drag our new scene into it
@export var goal_item_scene: PackedScene

# 2. Track the active UI elements. Key: goal_id, Value: GoalItemUI instance
var active_ui_elements: Dictionary = {}

func _ready() -> void:
	# Listen to the GoalManager's signals
	GoalManager.goal_activated.connect(_on_goal_activated)
	GoalManager.goal_progress_updated.connect(_on_goal_progress_updated)
	GoalManager.goal_completed.connect(_on_goal_completed)

func _on_goal_activated(goal: GoalData) -> void:
	# 1. Create a new instance of our reusable UI scene
	var new_item = goal_item_scene.instantiate() as GoalItemUI
	
	# 2. Add it as a child of this VBoxContainer so it shows up on screen
	add_child(new_item)
	
	# 3. Pass the goal data to it so it sets up its text and max values
	new_item.setup(goal)
	
	# 4. Save a reference to it in our dictionary so we can find it later
	active_ui_elements[goal.goal_id] = new_item

func _on_goal_progress_updated(goal_id: String, current: int, target: int) -> void:
	# Find the specific UI element for this goal and tell it to update
	if active_ui_elements.has(goal_id):
		active_ui_elements[goal_id].update_progress(current, target)

func _on_goal_completed(goal_id: String) -> void:
	# When the goal is finished, find the UI element...
	if active_ui_elements.has(goal_id):
		var item_to_remove = active_ui_elements[goal_id]
		
		# ...delete it from the screen...
		item_to_remove.queue_free()
		
		# ...and remove it from our tracking dictionary.
		active_ui_elements.erase(goal_id)
