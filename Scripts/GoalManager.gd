extends Node

signal goal_progress_updated(goal_id: String, current: int, target: int)

# A dictionary to track active goals. 
# Key: goal_id (String), Value: current_progress (int)
var active_goals: Dictionary = {}
var goal_definitions: Dictionary = {} # Stores the GoalData resources

# Call this when the level starts to load in the level's specific goals
func load_goals(goals_array: Array[GoalData]):
	active_goals.clear()
	goal_definitions.clear()
	for goal in goals_array:
		goal_definitions[goal.goal_id] = goal
		active_goals[goal.goal_id] = 0

# The pipeline script calls this when a player does something good
func add_progress(goal_id: String, amount: int = 1):
	if active_goals.has(goal_id):
		active_goals[goal_id] += amount
		var target = goal_definitions[goal_id].target_value
		
		goal_progress_updated.emit(goal_id, active_goals[goal_id], target)
		
		if active_goals[goal_id] >= target:
			complete_goal(goal_id)

func complete_goal(goal_id: String):
	var reward = goal_definitions[goal_id].reward_amount
	print("Goal Completed: ", goal_id)
	
	# Talk to the other Autoload to give the player money!
	EconomyManager.add_money(reward)
	EconomyManager.goal_completed.emit(goal_id, reward)
	
	# Remove from active goals so it can't be completed twice
	active_goals.erase(goal_id)
