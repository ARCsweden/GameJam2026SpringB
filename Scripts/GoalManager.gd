extends Node

signal goal_progress_updated(goal_id: String, current: int, target: int)
signal goal_activated(goal: GoalData)
signal goal_completed(goal_id: String) # New signal to tell the UI a goal is done!

# A dictionary to track active goals. 
# Key: goal_id (String), Value: current_progress (int)
var active_goals: Dictionary = {}
var goal_definitions: Dictionary = {} # Stores the GoalData resources

# METHOD A: Add an entire array of goals at the start of a level
func load_level_goals(goals_array: Array[GoalData]) -> void:
	active_goals.clear()
	goal_definitions.clear()
	
	for goal in goals_array:
		activate_single_goal(goal)

# METHOD B: Add a single goal dynamically
func activate_single_goal(base_goal: GoalData) -> void:
	# First check if it's already active to prevent duplicates
	if not active_goals.has(base_goal.goal_id):
		var goal = base_goal.duplicate()
		# 1. Save the Resource data so we know the target and reward later
		goal_definitions[goal.goal_id] = goal
		# 2. Add it to active goals and set its starting progress to 0
		active_goals[goal.goal_id] = 0
		
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
	# A temporary list to hold goals that finish during this loop
	var goals_to_complete: Array[String] = []
	
	# 1. Loop through every currently active goal
	for goal_id in active_goals.keys():
		var goal_data = goal_definitions[goal_id]
		
		# 2. Check if this goal cares about the action that just happened
		if goal_data.action_tag == action:
			
			# 3. Add progress and tell the UI to update
			active_goals[goal_id] += amount
			var target = goal_data.target_value
			goal_progress_updated.emit(goal_id, active_goals[goal_id], target)
			
			# 4. If it hit the target, mark it for completion!
			if active_goals[goal_id] >= target:
				goals_to_complete.append(goal_id)
				
	# 5. Safely finish and remove the goals after the loop is done
	for finished_goal_id in goals_to_complete:
		_finish_and_remove_goal(finished_goal_id)
	
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

func complete_goal(goal_id: String):
	var completed_goal_data = goal_definitions[goal_id]
	var reward = goal_definitions[goal_id].reward_amount
	print("Goal Completed: ", goal_id)
	# Talk to the other Autoload to give the player money!
	EconomyManager.add_money(reward)
	EconomyManager.goal_completed.emit(goal_id, reward)
	
	for next_goal in completed_goal_data.next_goals:
		print("Next goal", next_goal)
		if next_goal != null:
			activate_single_goal(next_goal)
			print("New goal added", next_goal)
	
	if completed_goal_data.is_repeatable:
		# Reset the progress back to 0
		active_goals[goal_id] = 0
		
		# Tell the UI to update the visual bar back down to 0
		goal_progress_updated.emit(goal_id, 0, completed_goal_data.target_value)
		print("Repeatable Goal Reset: ", goal_id)
	else:
		# Remove from active goals so it can't be completed twice
		active_goals.erase(goal_id)
		goal_definitions.erase(goal_id)
		print("Goal Completed and Removed")
		
func _finish_and_remove_goal(goal_id: String) -> void:
	# Grab the data before we do anything
	var completed_goal_data = goal_definitions[goal_id]
	var reward = completed_goal_data.reward_amount
	
	# 1. Give the player their money!
	EconomyManager.add_money(reward)
	
	# 2. Trigger the next goals in the chain (if there are any)
	for next_goal in completed_goal_data.next_goals:
		if next_goal != null:
			activate_single_goal(next_goal)
			
	# 3. --- THE REPEATABLE LOGIC ---
	if completed_goal_data.is_repeatable:
		# 1. Multiply the target and reward for the NEXT round (convert float back to int)
		completed_goal_data.target_value = int(completed_goal_data.target_value * completed_goal_data.target_multiplier)
		completed_goal_data.reward_amount = int(completed_goal_data.reward_amount * completed_goal_data.reward_multiplier)
		
		# Reset the progress back to 0
		active_goals[goal_id] = 0
		
		# Tell the UI to update the visual bar back down to 0
		goal_progress_updated.emit(goal_id, 0, completed_goal_data.target_value)
		print("Repeatable Goal Reset: ", goal_id)
		
	else:
		# It's a one-time goal. Tell the UI to delete it entirely.
		goal_completed.emit(goal_id)
		
		# Erase it from the backend dictionaries
		active_goals.erase(goal_id)
		goal_definitions.erase(goal_id)
		print("Goal Completed and Removed: ", goal_id)
	
