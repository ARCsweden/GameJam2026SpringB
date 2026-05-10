extends SchematicsNode
class_name GoalSchematicNode

@onready var bars_container: VBoxContainer = $BarsContainer

var my_goal_id: String = ""

# Dictionaries to quickly find the right UI elements when a signal arrives
var progress_bars: Dictionary = {}
var labels: Dictionary = {}

func setup(goal: GoalData) -> void:
	my_goal_id = goal.goal_id
	
	# Generate UI for every requirement
	for req in goal.requirements:
		var item_container = VBoxContainer.new()
		var lbl = Label.new()
		var pb = ProgressBar.new()
		
		lbl.text = req.description + " (0/" + str(req.target_value) + ")"
		pb.max_value = req.target_value
		pb.value = 0
		pb.custom_minimum_size = Vector2(100, 15)
		
		item_container.add_child(lbl)
		item_container.add_child(pb)
		bars_container.add_child(item_container)
		
		# Save them to our dictionaries using the action_tag as the Key
		progress_bars[req.action_tag] = pb
		labels[req.action_tag] = lbl
	
	GoalManager.goal_progress_updated.connect(_on_progress_updated)
	GoalManager.goal_completed.connect(_on_goal_completed)

# Notice the new 'action_tag' parameter here!
func _on_progress_updated(goal_id: String, action_tag: String, current: int, target: int) -> void:
	if goal_id == my_goal_id:
		# Check if we have a progress bar for this specific tag
		if progress_bars.has(action_tag):
			progress_bars[action_tag].value = current
			
			# Find the description from the GoalManager to format the text
			var desc = ""
			for req in GoalManager.goal_definitions[goal_id].requirements:
				if req.action_tag == action_tag:
					desc = req.description
					break
					
			labels[action_tag].text = desc + " (" + str(current) + "/" + str(target) + ")"
func _on_goal_completed(goal_id: String) -> void:
	if goal_id == my_goal_id:
		# The goal is done! Play a sound/particle here if you want, then delete it.
		SignalBus.spawn_goal_done_effect.emit(global_position + get_center())
		print("Goal Node Destroyed: ", goal_id)
		# Remove active connections
		for c in slots.get_children():
			var slot = c as NodeSlot
			SignalBus.connection_removed.emit(slot.connection)
		queue_free()

# Add your get_center() function here if your drag logic requires it!
func get_center() -> Vector2:
	return Vector2.ONE * 16
	

func _on_area_2d_mouse_entered() -> void:
	SignalBus.node_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	SignalBus.node_exited.emit(self)
