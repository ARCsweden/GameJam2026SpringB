extends Node

signal goal_progress_updated(goal_id: String, action_tag: String, current: int, target: int)
signal goal_activated(goal: GoalData)
signal goal_completed(goal_id: String) # New signal to tell the UI a goal is done!

# A dictionary to track active goals. 
# Key: goal_id (String), Value: current_progress (int)
var active_goals: Dictionary = {}
var goal_definitions: Dictionary = {} # Stores the GoalData resources


func _ready() -> void:
	#SignalBus.update_slot_flow.connect(on_graph_changed)
	#SignalBus.disconnect_slot_flow.connect(on_graph_changed)
	SignalBus.flow_updated.connect(on_graph_changed)

# METHOD A: Add an entire array of goals at the start of a level
func load_level_goals(goals_array: Array[GoalData]) -> void:
	active_goals.clear()
	goal_definitions.clear()
	
	for goal in goals_array:
		activate_single_goal(goal)

# --- 1. THE UNLOCKER (Sends the goal to the Store) ---
func unlock_goal_for_store(base_goal: GoalData) -> void:
	# We don't track progress yet! We just tell the UI to create a button.
	print("Goal Unlocked in Store: ", base_goal.goal_id)
	SignalBus.goal_unlocked.emit(base_goal)

# METHOD B: Add a single goal dynamically
func activate_single_goal(base_goal: GoalData) -> void:
	# First check if it's already active to prevent duplicates
	if not active_goals.has(base_goal.goal_id):
		var goal = base_goal.duplicate()
		# 1. Save the Resource data so we know the target and reward later
		goal_definitions[goal.goal_id] = goal
		
		var progress_dict = {}
		for req in goal.requirements:
			progress_dict[req.action_tag]=0
		
		# 2. Add it to active goals and set its starting progress to 0
		active_goals[goal.goal_id] = progress_dict
		
		print("New Goal Added: ", goal.goal_id)
		goal_activated.emit(goal)
		
		
# Call this when the level starts to load in the level's specific goals
func load_goals(goals_array: Array[GoalData]):
	active_goals.clear()
	goal_definitions.clear()
	for goal in goals_array:
		goal_definitions[goal.goal_id] = goal
		active_goals[goal.goal_id] = 0
# Replace add_progress with this new function:
func trigger_action(action: String, amount: int = 1) -> void:
	var goals_to_complete: Array[String] = []
	
		
	for goal_id in active_goals.keys():
		var goal_data = goal_definitions[goal_id]
		var progress = active_goals[goal_id] # This is now a Dictionary
		# Does this goal care about the action that just happened?
		if goal_data.logic_type == 	GoalData.LogicType.PASSIVE:
			if progress.has(action):
				progress[action] += amount
				
				# Find the target value for this specific action
				var target = 0
				for req in goal_data.requirements:
					if req.action_tag == action:
						target = req.target_value
						break
						
				# Tell the UI to update this specific bar
				goal_progress_updated.emit(goal_id, action, progress[action], target)
				
				# Check if the ENTIRE goal is finished
				if _is_goal_complete(goal_id):
					goals_to_complete.append(goal_id)
					
	for finished_goal_id in goals_to_complete:
		_finish_and_remove_goal(finished_goal_id)

func on_graph_changed(start, end) -> void:
	var goals_to_complete: Array[String] = []
	# This function triggers on every graph change
	if active_goals:
		# Checks if any graph change affects an investor node
		var investor_node: GoalSchematicNode = null
		if start.parent_node is GoalSchematicNode:
			investor_node = start.parent_node
		if end.parent_node is GoalSchematicNode:
			investor_node = end.parent_node
		if investor_node:
			print(investor_node.my_goal_id)
			print(investor_node.slots)
			
			# Finds all input slots
			var input_resource_slots = []
			for c in investor_node.slots.get_children():
				var ns : NodeSlot = c as NodeSlot
				if ns.dir == ResourceTypes.DIR.IN and ns.type != ResourceTypes.RT.POWER:
					input_resource_slots.append(ns)
			# Sums all inputs
			var total_arr = []
			for a in ResourceTypes.RT.size():
				total_arr.append(0)
			for s_i in input_resource_slots:
				for i in ResourceTypes.RT.size():
					total_arr[i] += s_i.amount_arr[i]
			print(total_arr)
		
		# Get Network state of connection
			for goal_id in active_goals.keys():
				var goal_data = goal_definitions[goal_id]
				var progress = active_goals[goal_id]
				if goal_data.logic_type == GoalData.LogicType.ACTIVE:
					if investor_node.my_goal_id == goal_id:
						
						var is_fully_complete = true
						
						# 1. Loop through every requirement for this specific goal
						for req in goal_data.requirements:
							
							# 2. Match the string tag (e.g., "COMPUTE") to the Enum index
							# .to_upper() ensures it matches even if you typed "compute" in the inspector
							var enum_string = req.action_tag.to_upper() 
							
							if ResourceTypes.RT.has(enum_string):
								var resource_index = ResourceTypes.RT[enum_string]
								
								# 3. Get the actual amount currently flowing into the node
								var current_amount = total_arr[resource_index]
								
								# 4. Save it in the progress dictionary
								progress[req.action_tag] = current_amount
								
								# 5. Emit the signal! This is what physically moves the UI progress bars!
								goal_progress_updated.emit(goal_id, req.action_tag, current_amount, req.target_value)
								
								# 6. Check if this specific requirement is lacking
								if current_amount < req.target_value:
									is_fully_complete = false
							else:
								print("ERROR: action_tag '", req.action_tag, "' does not exist in ResourceTypes.RT!")
								is_fully_complete = false
								
						# 7. If the loop finishes and nothing was lacking, the goal is done!
						if is_fully_complete:
							goals_to_complete.append(goal_id)
							
			# 8. Safely process completions outside the dictionary loop
			for finished_goal in goals_to_complete:
				_finish_and_remove_goal(finished_goal)
			#if goal_data.logic_type == GoalData.LogicType.ACTIVE:
		#		if investor_node.my_goal_id == goal_id:
			#		pass
			#var goal_data = goal_definitions[goal_id]
			
		#if goal_id.logic_type == GoalData.LogicType.ACTIVE:
		#	pass
		#	var target = 0
		#	for req in goal_data.requirements:
		#			target = req.target_value
		#			break
		#	pass
		else:
			return



# Helper function to check if all requirements hit their target
func _is_goal_complete(goal_id: String) -> bool:
	var goal_data = goal_definitions[goal_id]
	var progress = active_goals[goal_id]
	
	for req in goal_data.requirements:
		if progress[req.action_tag] < req.target_value:
			return false # Found one that isn't done yet!
			
	return true # All requirements met!
# The pipeline script calls this when a player does something good
#func add_progress(goal_id: String, amount: int = 1):
#	print("Goal Process")
#	if active_goals.has(goal_id):
#		active_goals[goal_id] += amount
#		var target = goal_definitions[goal_id].target_value
#		print("Update Process", goal_id)
#		goal_progress_updated.emit(goal_id, active_goals[goal_id], target)
#		
#		if active_goals[goal_id] >= target:
#			complete_goal(goal_id)

func _finish_and_remove_goal(goal_id: String) -> void:
	# Grab the data before we do anything
	var completed_goal_data = goal_definitions[goal_id]
	var reward = completed_goal_data.reward_amount
	
	# 1. Give the player their money!
	EconomyManager.add_money(reward)
	
	# 2. Trigger the next goals in the chain (if there are any)
	for next_goal in completed_goal_data.next_goals:
		if next_goal != null:
			unlock_goal_for_store(next_goal)
			
	# 3. --- THE REPEATABLE LOGIC ---
	if completed_goal_data.is_repeatable:
		
		# Scale the overall reward for the next tier
		completed_goal_data.reward_amount = int(completed_goal_data.reward_amount * completed_goal_data.reward_multiplier)
		
		# Loop through EVERY requirement and scale its specific target value
		for req in completed_goal_data.requirements:
			req.target_value = int(req.target_value * completed_goal_data.target_multiplier)
		
		# Tell the board to DESTROY the node!
		goal_completed.emit(goal_id)
		
		# STOP tracking it on the board
		active_goals.erase(goal_id)
		# We also remove it from the board definitions so it doesn't leave ghost data
		goal_definitions.erase(goal_id)
		
		# Send the newly scaled clone back to the Store!
		unlock_goal_for_store(completed_goal_data)
		print("Repeatable Goal scaled and returned to store! ", goal_id)
	else:
		# It's a one-time goal. Tell the UI to delete it entirely.
		goal_completed.emit(goal_id)
		
		# Erase it from the backend dictionaries
		active_goals.erase(goal_id)
		goal_definitions.erase(goal_id)
		print("Goal Completed and Removed: ", goal_id)
	
