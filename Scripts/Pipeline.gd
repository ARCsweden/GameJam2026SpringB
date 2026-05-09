class_name PipeLine

extends Node
#lives on a output from a node, connects to the input of another.

var PipelineType: String
var Endpoint: Node2D
var PipelineNode: Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PipelineType = self.get_meta("type", null)

#func _process(_delta: float) -> void:
#	pass

func _on_click_input(): #make this happen whenver the object this placed on is clicked.
	SignalBus.click_cancel.emit()
	#SignalBus.click_output.connect()
	#SignalBus.click_cancel.connect()
	print("listening for output clicks")

func _on_click_output(object):
	join(object)
	#SignalBus.click_output.disconnect()
	#SignalBus.click_cancel.disconnect()
	print("output heard")

func _on_click_cancel():
	#SignalBus.click_output.disconnect()
	#SignalBus.click_cancel.disconnect()
	print("linking cancelled")

func join(endpoint: Node2D):
	if endpoint.get_meta("type", null) == PipelineType:
		Endpoint = endpoint
		draw()
		print("input output linked")
	else: #missmatched types
		print("missmatched types")
	
func _free():
	Endpoint = null
	draw()
	_on_click_cancel()

func draw():
	if self!=null and Endpoint!=null: #both points exists
		PipelineNode = Line2D.new()
		self.add_child(PipelineNode)
		PipelineNode.add_point(self.global_position)
		PipelineNode.add_point(Endpoint.global_position)
	else: #both points does not exist
		PipelineNode.clear_points()
		self.remove_child(PipelineNode)
		PipelineNode.free()
	pass
