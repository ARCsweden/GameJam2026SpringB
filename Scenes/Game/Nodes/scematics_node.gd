class_name SchematicsNode
extends Node2D

var ns_scene : PackedScene = preload("res://Scenes/Game/Nodes/node_slot.tscn")

@onready var move_icon : Sprite2D = $MoveIcon
@onready var ninepatch : NinePatchRect = $NinePatchRect
@onready var slots : Node2D = $Slots
@onready var name_label : Label = %NodeName

const MOVE_OFFSET: int = 16
const SLOT_OFFSET: int = 32

#TODO: Common logic for all nodes (drag and drop)

func _ready() -> void:
	init_slots()
	move_icon.position = get_center()


func init_slots() -> void:
	for c in slots.get_children():
		var ns : NodeSlot = c as NodeSlot
		ns.parent_node = self


func create_node_slot(nsd: NodeSlotData, pos: Vector2i) -> void:
	var ns_instance: NodeSlot = ns_scene.instantiate()
	ns_instance.texture = nsd.texture
	ns_instance.dir = nsd.direction
	ns_instance.type = nsd.type
	ns_instance.position = pos

	if nsd.provider:
		if nsd.type == ResourceTypes.RT.POWER:
			ns_instance.amount_arr[nsd.type] = 1
		else:
			ns_instance.powered_amount_arr[nsd.type] = 1

	slots.add_child(ns_instance)


func get_slots(node_data: NodeData, sa: Array[NodeSlotData], horizontal: bool) -> int:
	var n_slot: int = sa.size() + 1
	if horizontal:
		if node_data.left_slots:
			n_slot += 1
		if node_data.right_slots:
			n_slot += 1
	else:
		if node_data.top_slots:
			n_slot += 1
		if node_data.bottom_slots:
			n_slot += 1
	return n_slot


# Function that takes a NodeData resource and creates the node slots from it
# Assumes there are no slots currently
func setup_node(node_data: NodeData) -> void:
	ninepatch.size = node_data.size
	ninepatch.modulate = node_data.color
	
	name_label.size.x = node_data.size.x
	name_label.text = node_data.node_name

	if node_data.top_slots:
		var n_slot = get_slots(node_data, node_data.top_slots, true)
		var offset: int = (int)((float)(node_data.size.x) / n_slot)
		var start: Vector2i = Vector2i(offset, SLOT_OFFSET)
		var stride: Vector2i = Vector2i(offset, 0)
		if node_data.left_slots:
			start += stride
		for nsd in node_data.top_slots:
			create_node_slot(nsd, start)
			start += stride
	if node_data.bottom_slots:
		var n_slot = get_slots(node_data, node_data.bottom_slots, true)
		var offset: int = (int)((float)(node_data.size.x) / n_slot)
		var start: Vector2i = Vector2i(offset, node_data.size.y - SLOT_OFFSET)
		var stride: Vector2i = Vector2i(offset, 0)
		if node_data.left_slots:
			start += stride
		for nsd in node_data.bottom_slots:
			create_node_slot(nsd, start)
			start += stride
	if node_data.left_slots:
		var n_slot = get_slots(node_data, node_data.left_slots, false)
		var offset: int = (int)((float)(node_data.size.y) / n_slot)
		var start: Vector2i = Vector2i(SLOT_OFFSET, offset)
		var stride: Vector2i = Vector2i(0, offset)
		if node_data.top_slots:
			start += stride
		for nsd in node_data.left_slots:
			create_node_slot(nsd, start)
			start += stride
	if node_data.right_slots:
		var n_slot = get_slots(node_data, node_data.right_slots, false)
		var offset: int = (int)((float)(node_data.size.y) / n_slot)
		var start: Vector2i = Vector2i(node_data.size.x - SLOT_OFFSET, offset)
		var stride: Vector2i = Vector2i(0, offset)
		if node_data.top_slots:
			start += stride
		for nsd in node_data.right_slots:
			create_node_slot(nsd, start)
			start += stride
	init_slots()


func get_center() -> Vector2:
	return Vector2.ONE * MOVE_OFFSET


func _on_area_2d_mouse_entered() -> void:
	SignalBus.node_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	SignalBus.node_exited.emit(self)
