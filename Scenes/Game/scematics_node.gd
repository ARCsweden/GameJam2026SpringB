extends Node2D


@onready var ninepatch : NinePatchRect = $NinePatchRect

@onready var inputs : Node2D = $InputSlots
@onready var outputs : Node2D = $OutputSlots
@onready var power : Node2D = $PowerSlots

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
