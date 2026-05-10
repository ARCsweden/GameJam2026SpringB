extends Control

@onready var popup_scene : PackedScene = preload("res://Scenes/UI/mission_story_popup.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.show_goal_story.connect(_on_show_goal_story)


func _on_show_goal_story(goal: GoalData) -> void:
	if goal:
		var popup = popup_scene.instantiate()
		add_child(popup)
		popup.set_goal(goal)
