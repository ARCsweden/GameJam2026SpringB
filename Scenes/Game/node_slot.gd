class_name NodeSlot
extends Node2D

@onready var area2d : Area2D = $Area2D
@onready var activation_sprite : Sprite2D = $ActivationSprite

@export var type : ResourceTypes.RT
@export var dir : ResourceTypes.DIR

@export var base_power_amount = 0
@export var powered_vision_amount = 0
@export var powered_compute_amount = 0
@export var powered_motion_amount = 0
@export var unpowered_vision_amount = 0
@export var unpowered_compute_amount = 0
@export var unpowered_motion_amount = 0

var amount_arr = []

var connection : Connection = null
var parent_node : SchematicsNode = null

func _ready():
	for a in ResourceTypes.RT.size():
		amount_arr.append(0)
	amount_arr[ResourceTypes.RT.POWER] = base_power_amount
	amount_arr[ResourceTypes.RT.VISION] = 0
	amount_arr[ResourceTypes.RT.COMPUTE] = 0
	amount_arr[ResourceTypes.RT.MOTION] = 0
	
func _process(delta: float) -> void:
	$Label.text = "P: " + str(amount_arr[0]) + "\nV: " + str(amount_arr[1]) + "\nC: " + str(amount_arr[2]) + "\nM: " + str(amount_arr[3])

func _on_slot_entered():
	SignalBus.slot_entered.emit(self)
	activation_sprite.show()

func _on_slot_exited():
	SignalBus.slot_exited.emit(self)
	activation_sprite.hide()
