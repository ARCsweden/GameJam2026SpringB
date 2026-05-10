extends HBoxContainer

@onready var target_name = %TargetName
@onready var target_label = %TargetLabel

func setup(req: GoalRequirement) -> void:
	target_name.text = req.description
	target_label.text = str(req.target_value)
