extends Resource
class_name NodeData

@export var node_name: String
@export var left_slots: Array[NodeSlotData]
@export var right_slots: Array[NodeSlotData]
@export var top_slots: Array[NodeSlotData]
@export var bottom_slots: Array[NodeSlotData]

@export var size: Vector2i = Vector2i(64, 64)
@export var color: Color = Color.WHITE
