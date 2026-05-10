class_name NodeSlot
extends Node2D

@onready var area2d : Area2D = $Area2D
@onready var sprite : Sprite2D = $Sprite
@onready var activation_sprite : Sprite2D = $ActivationSprite

@export var texture : Texture2D
@export var type : ResourceTypes.RT
@export var dir : ResourceTypes.DIR

@export var base_power_amount = 0
@export var powered_vision_amount = 0
@export var powered_compute_amount = 0
@export var powered_motion_amount = 0
@export var unpowered_vision_amount = 0
@export var unpowered_compute_amount = 0
@export var unpowered_motion_amount = 0

var unpowered_amount_arr = []
var powered_amount_arr = []
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
	
	for a in ResourceTypes.RT.size():
		powered_amount_arr.append(0)
	powered_amount_arr[ResourceTypes.RT.POWER] = 0
	powered_amount_arr[ResourceTypes.RT.VISION] = powered_vision_amount
	powered_amount_arr[ResourceTypes.RT.COMPUTE] = powered_compute_amount
	powered_amount_arr[ResourceTypes.RT.MOTION] = powered_motion_amount

	for a in ResourceTypes.RT.size():
		unpowered_amount_arr.append(0)
	unpowered_amount_arr[ResourceTypes.RT.POWER] = 0
	unpowered_amount_arr[ResourceTypes.RT.VISION] = unpowered_vision_amount
	unpowered_amount_arr[ResourceTypes.RT.COMPUTE] = unpowered_compute_amount
	unpowered_amount_arr[ResourceTypes.RT.MOTION] = unpowered_motion_amount
	
	sprite.texture = texture
	
func _process(delta: float) -> void:
	pass	

func _on_slot_entered():
	SignalBus.slot_entered.emit(self)
	activation_sprite.show()

func _on_slot_exited():
	SignalBus.slot_exited.emit(self)
	activation_sprite.hide()
