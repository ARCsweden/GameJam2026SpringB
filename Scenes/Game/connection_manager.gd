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
				if end and _is_conn_valid(start, end):
					var connection = Connection.new()
					connection.line = line
					connection.start = start
					connection.end = end
					start.connection = connection
					end.connection = connection
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
				# Remove existing line
				if start.connection:
					# Make the other side of the existing connection the start
					var conn = start.connection
					if conn.start == start:
						start = conn.end
						line.add_point(conn.end.global_position)
					else:
						start = conn.start
						line.add_point(conn.start.global_position)
					line.add_point(get_global_mouse_position())
					# Cleanup old line/connection
					remove_child(conn.line)
					connections.erase(conn)
					conn.start.connection = null
					conn.end.connection = null
				else:
					# New line, starting at start node
					line.add_point(start.global_position)
					line.add_point(get_global_mouse_position())
				add_child(line)

func _is_conn_valid(n1: NodeSlot, n2: NodeSlot) -> bool:
	return n1.type == n2.type and n1.dir != n2.dir and n1.connection == null and n2.connection == null

func _on_slot_entered(node: NodeSlot) -> void:
	if line:
		end = node
		if _is_conn_valid(start, end):
			line.modulate = Color.GREEN
		else:
			line.modulate = Color.RED
	else:
		start = node

func _on_slot_exited(_node: NodeSlot) -> void:
	if line:
		end = null
		line.modulate = Color.WHITE
	else:
		start = null
