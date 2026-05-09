extends SchematicsNode
class_name GoalSchematicNode

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var label: Label = $VBoxContainer/Label

var my_goal_id: String = ""

# Called by the Schematic exactly when it spawns
func setup(goal: GoalData) -> void:
	my_goal_id = goal.goal_id
	
	# Setup visuals
	progress_bar.max_value = goal.target_value
	progress_bar.value = 0
	label.text = goal.description + " (0/" + str(goal.target_value) + ")"
	
	# Listen to the GoalManager!
	GoalManager.goal_progress_updated.connect(_on_progress_updated)
	GoalManager.goal_completed.connect(_on_goal_completed)

func _on_progress_updated(goal_id: String, current: int, target: int) -> void:

	if goal_id == my_goal_id:
		progress_bar.value = current
		label.text = GoalManager.goal_definitions[goal_id].description + " (" + str(current) + "/" + str(target) + ")"

func _on_goal_completed(goal_id: String) -> void:
	if goal_id == my_goal_id:
		# The goal is done! Play a sound/particle here if you want, then delete it.
		print("Goal Node Destroyed: ", goal_id)
		queue_free()

# Add your get_center() function here if your drag logic requires it!
func get_center() -> Vector2:
	return Vector2.ONE * 16
	

func _on_area_2d_mouse_entered() -> void:
	SignalBus.node_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	SignalBus.node_exited.emit(self)
