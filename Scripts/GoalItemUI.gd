extends VBoxContainer
class_name GoalItemUI

@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar

var base_description: String = ""

# Called once when the goal is first activated
func setup(goal: GoalData) -> void:
	print("SETUP GOALS TO XX")
	base_description = goal.description
	progress_bar.max_value = goal.target_value
	update_progress(0, goal.target_value)

# Called every time progress is made
func update_progress(current: int, target: int) -> void:
	progress_bar.max_value = target
	progress_bar.value = current
	# Using Godot's string formatting to make it look like: "Buy CPU (1/2)"
	label.text = "%s (%d/%d)" % [base_description, current, target]
