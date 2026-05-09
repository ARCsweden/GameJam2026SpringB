class_name NodeSlot
extends Node2D

@onready var area2d : Area2D = $Area2D
@onready var activation_sprite : Sprite2D = $ActivationSprite

@export var type : ResourceTypes.RT
@export var dir : ResourceTypes.DIR
@export var base_amount = 1

var amount

var connection : Connection = null
var parent_node : SchematicsNode = null

func _ready():
	if dir == ResourceTypes.DIR.OUT and type == ResourceTypes.RT.POWER:
		amount = base_amount
	else:
		amount = 0
	
func _process(delta: float) -> void:
	$Label.text = str(amount)

func _on_slot_entered():
	SignalBus.slot_entered.emit(self)
	activation_sprite.show()

func _on_slot_exited():
	SignalBus.slot_exited.emit(self)
	activation_sprite.hide()
