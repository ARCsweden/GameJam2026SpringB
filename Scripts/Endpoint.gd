extends Node

signal buffer(amount: int)

var something = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void: #put the current output rate to the signal.
	self.buffer.emit(something)

#func _input() -> void: #should happen whenver object it is attached to is clicked
#	SignalBus.click_output.emit(self)
