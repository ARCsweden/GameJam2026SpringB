extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connection_made.connect(_on_connection_made)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_connection_made():
	print("Connection made!")
