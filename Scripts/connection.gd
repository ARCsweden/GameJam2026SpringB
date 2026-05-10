class_name Connection
extends Node

var line : Line2D = null
var start : NodeSlot = null
var end : NodeSlot = null
var connection_type : ResourceTypes.RT

func update_line() -> void:
	if line and start and end:
		line.points[0] = start.global_position
		line.points[1] = end.global_position

func remove() -> void:
	if start:
		start.connection = null
	if end:
		end.connection = null
	line.queue_free()
