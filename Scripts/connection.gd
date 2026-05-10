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
		set_label_text()
		between.x -= label.size.x / 2
		between.x -= label.size.y / 2
		label.set_position(between)

func remove() -> void:
	if start:
		start.connection = null
	if end:
		end.connection = null
	line.queue_free()
	
func set_label_text():
	var text = ""
	if start.amount_arr[ResourceTypes.RT.POWER] != 0:
		text += "P:" + str(start.amount_arr[ResourceTypes.RT.POWER]) + " "
	if start.amount_arr[ResourceTypes.RT.VISION] != 0:
		text += "V:" + str(start.amount_arr[ResourceTypes.RT.VISION]) + " "
	if start.amount_arr[ResourceTypes.RT.COMPUTE] != 0:
		text += "C:" + str(start.amount_arr[ResourceTypes.RT.COMPUTE]) + " "
	if start.amount_arr[ResourceTypes.RT.MOTION] != 0:
		text += "M:" + str(start.amount_arr[ResourceTypes.RT.MOTION]) + " "
	label.text = text

	
