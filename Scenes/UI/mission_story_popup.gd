extends Control

@export var goal_data : GoalData

@onready var title : Label = %Title
@onready var story : RichTextLabel = %StoryText
@onready var reward : Label = %RewardLabel
@onready var vbox : VBoxContainer = %VContainer

@onready var target_scene : PackedScene = preload("res://Scenes/UI/mission_story_popup_target.tscn")

func _ready() -> void:
	if goal_data:
		set_goal(goal_data)

func set_goal(goal: GoalData) -> void:
	title.text = goal.description
	story.text = goal.goal_text
	reward.text = str(goal.reward_amount)
	for req in goal.requirements:
		var target = target_scene.instantiate()
		vbox.add_child(target)
		target.setup(req)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("cancel"):
		queue_free()


func _on_exit_button_pressed() -> void:
	queue_free()
