extends VBoxContainer

# Grab references to our progress bar nodes
@onready var cpu_progress: ProgressBar = $CPUProgressBar
@onready var gpu_progress: ProgressBar = $GPUProgressBar

func _ready() -> void:
	# 1. Listen to the global goal updates
	GoalManager.goal_progress_updated.connect(_on_goal_progress_updated)
	
	# 2. Set the target goals (2 CPUs, 2 GPUs)
	cpu_progress.max_value = 3
	gpu_progress.max_value = 3
	print("Goal = 2")
	
	# 3. Start them at 0
	cpu_progress.value = 0
	gpu_progress.value = 0

# This triggers every time GoalManager.add_progress() is called
func _on_goal_progress_updated(goal_id: String, current: int, target: int) -> void:
	# Check which goal was updated and fill the correct bar
	print("GOAL UPDATE")
	if goal_id == "buy_cpu":
		cpu_progress.value = current
	elif goal_id == "buy_gpu":
		gpu_progress.value = current
		
	# Optional: Check if both are done to trigger a master event
	if cpu_progress.value == cpu_progress.max_value and gpu_progress.value == gpu_progress.max_value:
		print("LEVEL COMPLETE: Both CPU and GPU goals met!")
