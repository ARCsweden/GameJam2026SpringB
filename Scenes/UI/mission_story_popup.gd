extends Control

@export var goal_data : GoalData

@onready var title : Label = %Title
@onready var story : RichTextLabel = %StoryText
@onready var reward : Label = %RewardLabel
@onready var target : Label = %TargetLabel

func _ready() -> void:
	if goal_data:
		set_goal(goal_data)

func set_goal(goal: GoalData) -> void:
	title.text = goal.description
	reward.text = str(goal.reward_amount)
	target.text = str(goal.target_value)


func _on_exit_button_pressed() -> void:
	queue_free()
