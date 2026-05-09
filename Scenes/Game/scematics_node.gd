extends Node2D


@onready var ninepatch : NinePatchRect = $NinePatchRect

@onready var inputs : Node2D = $InputSlots
@onready var outputs : Node2D = $OutputSlots
@onready var power : Node2D = $PowerSlots

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#TODO: Clear placeholders
	return
	for n in inputs.get_children():
		inputs.remove_child(n)
		n.queue_free()
	for n in outputs.get_children():
		outputs.remove_child(n)
		n.queue_free()
	for n in power.get_children():
		power.remove_child(n)
		n.queue_free()

#TODO: Initialize node with the correct slots
