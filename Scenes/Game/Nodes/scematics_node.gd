class_name SchematicsNode
extends Node2D


@onready var move_icon : Sprite2D = $MoveIcon
@onready var ninepatch : NinePatchRect = $NinePatchRect
@onready var slots : Node2D = $Slots

#TODO: Common logic for all nodes (drag and drop)

func _ready() -> void:
	for c in slots.get_children():
		var ns : NodeSlot = c as NodeSlot
		ns.parent_node = self
	move_icon.position = get_center()


func get_center() -> Vector2:
	return Vector2.ONE * 16


func _on_area_2d_mouse_entered() -> void:
	SignalBus.node_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	SignalBus.node_exited.emit(self)
