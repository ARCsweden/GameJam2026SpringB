extends Node2D

const SFX_NODE_PRESS := "node_press"
const SFX_CONNECTION_VALID := "connection_valid"
const SFX_CONNECTION_INVALID := "connection_invalid"
const SFX_CONNECTION_CANCELLED := "connection_cancelled"

var line: Line2D = null
var start: NodeSlot = null
var end: NodeSlot = null
var connection_type: ResourceTypes.RT

var connections: Array[Connection] = []

func _ready() -> void:
	SignalBus.slot_entered.connect(_on_slot_entered)
	SignalBus.slot_exited.connect(_on_slot_exited)
	SignalBus.connection_removed.connect(_on_connection_removed)

func _process(_delta: float) -> void:
	for c in connections:
		c.update_line()

	if line:
		line.points[0] = start.global_position

		if end:
			line.points[1] = end.global_position
		else:
			line.points[1] = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed == false:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if line:
				_finish_connection()
			elif start:
				_start_connection()


func _start_connection() -> void:
	request_sfx(SFX_NODE_PRESS)

	line = Line2D.new()

	if start.connection:
		var conn: Connection = start.connection

		if conn.start == start:
			start = conn.end
			line.add_point(conn.end.global_position)
		else:
			start = conn.start
			line.add_point(conn.start.global_position)

		line.add_point(get_global_mouse_position())

		_on_connection_removed(conn)
	else:
		line.add_point(start.global_position)
		line.add_point(get_global_mouse_position())

	add_child(line)


func _finish_connection() -> void:
	var connection_created: bool = false

	if end:
		if _is_conn_valid(start, end):
			var connection: Connection = Connection.new()
			connection.line = line
			connection.start = start
			connection.end = end

			start.connection = connection
			end.connection = connection

			connections.append(connection)

			SignalBus.update_slot_flow.emit(start, end)

			request_sfx(SFX_CONNECTION_VALID)
			connection_created = true
		else:
			request_sfx(SFX_CONNECTION_INVALID)
	else:
		request_sfx(SFX_CONNECTION_CANCELLED)

	if not connection_created:
		remove_child(line)
		line.queue_free()

	line = null
	start = end
	end = null


func _is_conn_valid(n1: NodeSlot, n2: NodeSlot) -> bool:
	return n1.type == n2.type and n1.dir != n2.dir and n1.connection == null and n2.connection == null


func _on_connection_removed(conn: Connection) -> void:
	if conn:
		if conn.line:
			remove_child(conn.line)

		connections.erase(conn)
		conn.remove()


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


func request_sfx(sound_name: String) -> void:
	SignalBus.audio_sfx_requested.emit(sound_name)
