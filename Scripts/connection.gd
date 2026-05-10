class_name Connection
extends Node

var line : Line2D = null
var label: Label = null
var start : NodeSlot = null
var end : NodeSlot = null
var connection_type : ResourceTypes.RT

func update_line() -> void:
	if line and start and end:
		line.points[0] = start.global_position
		line.points[1] = end.global_position
		var between = line.points[0].lerp(line.points[1], 0.5)
		label.text = "P:" + str(start.amount_arr[0]) + " V: " + str(start.amount_arr[1]) + " C: " + str(start.amount_arr[2]) + " M: " + str(start.amount_arr[3])
		between.x -= label.size.x / 2
		between.x -= label.size.y / 2
		label.set_position(between)

func remove() -> void:
	if start:
		start.connection = null
	if end:
		end.connection = null
	line.queue_free()
