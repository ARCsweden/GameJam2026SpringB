extends PanelContainer # Or Button, depending on your setup
class_name GoalStoreItemUI

var my_goal: GoalData

func setup(goal: GoalData) -> void:
	my_goal = goal
	$VBoxContainer/TextureRect.texture = goal.icon
	$VBoxContainer/Label2.text = goal.description

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 1. Tell the schematic to spawn it!
			SignalBus.spawn_goal_from_store.emit(my_goal)
			
			# 2. It can only be placed once, so delete this button from the store!
			queue_free()
			
			accept_event()
