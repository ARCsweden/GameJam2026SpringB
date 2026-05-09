extends Node2D

var line : Line2D = null
var start : NodeSlot = null
var end : NodeSlot = null
var connection_type : ResourceTypes.RT = ResourceTypes.RT.NONE

var connections : Array[Connection] = []

func _ready() -> void:
	SignalBus.slot_entered.connect(_on_slot_entered)
	SignalBus.slot_exited.connect(_on_slot_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Update position of existing connections
	for c in connections:
		c.update_line()
	# Update position of line
	if line:
		line.points[0] = start.global_position
		if end:
			line.points[1] = end.global_position
		else:
			line.points[1] = get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed == false:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if line: # Finish connection
				# Add connection to list if the line is valid
				if end and start.type == end.type and start.dir != end.dir:
					var connection = Connection.new()
					connection.line = line
					connection.start = start
					connection.end = end
					connections.append(connection)
				# Clear old line/start/end
				else:
					remove_child(line)
					line.queue_free()
				line = null
				start = null
				end = null
			elif start: # Create new connection
				# Create line
				line = Line2D.new()
				line.add_point(start.global_position)
				line.add_point(get_global_mouse_position())
				add_child(line)

func _on_slot_entered(node: NodeSlot) -> void:
	if line:
		end = node
		if start.type != end.type or start.dir == end.dir:
			line.modulate = Color.RED
		else:
			line.modulate = Color.GREEN
	else:
		start = node

func _on_slot_exited(_node: NodeSlot) -> void:
	if line:
		end = null
		line.modulate = Color.WHITE
	else:
		start = null
