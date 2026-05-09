extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.connection_made.connect(_on_connection_made)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_connection_made(start_slot: NodeSlot, stop_slot: NodeSlot):
	# Add the following to each node: Input product, output product. 
	# If no power: 0 output.
	# When input or power state changes, update output. Then start going through all nodes connected
	# to the output and update those in turn.
	
	for c in start_slot.parent_node.slots.get_children():
		var ns : NodeSlot = c as NodeSlot
		print(c.dir, c.type)
	
