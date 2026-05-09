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

var power_amount = base_power_amount
var vision_amount = powered_vision_amount
var compute_amount = powered_compute_amount
var motion_amount = powered_motion_amount

var amount_arr = [power_amount, vision_amount, compute_amount, motion_amount]

var connection : Connection = null
var parent_node : SchematicsNode = null

func _ready():
	if dir == ResourceTypes.DIR.OUT and type == ResourceTypes.RT.POWER:
		power_amount = 1
	
func _process(delta: float) -> void:
	$Label.text = "P: " + str(power_amount) + "\nV: " + str(vision_amount) + "\nC: " + str(compute_amount) + "\nM: " + str(motion_amount)

func _on_slot_entered():
	SignalBus.slot_entered.emit(self)
	activation_sprite.show()

func _on_slot_exited():
	SignalBus.slot_exited.emit(self)
	activation_sprite.hide()
