class_name SchematicsNode
extends Node2D


@onready var ninepatch : NinePatchRect = $NinePatchRect
@onready var slots : Node2D = $Slots

#TODO: Common logic for all nodes (drag and drop)

func _ready() -> void:
	for c in slots.get_children():
		var ns : NodeSlot = c as NodeSlot
		ns.parent_node = self
