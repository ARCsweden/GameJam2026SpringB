class_name NodeSlot
extends Node2D

@onready var area2d : Area2D = $Area2D
@onready var sprite : Sprite2D = $Sprite
@onready var activation_sprite : Sprite2D = $ActivationSprite

@export var texture : Texture2D
@export var type : ResourceTypes.RT
@export var dir : ResourceTypes.DIR

var powered_amount_arr : Array[int] = []
var amount_arr : Array[int] = []

var connection : Connection = null
var parent_node = null


func _init() -> void:
	for a in ResourceTypes.RT.size():
		amount_arr.append(0)
		powered_amount_arr.append(0)


func _ready():
	sprite.texture = texture


func _process(_delta: float) -> void:
	$DebugLabel.text = "P: " + str(amount_arr[0]) + "\nV: " + str(amount_arr[1]) + "\nC: " + str(amount_arr[2]) + "\nM: " + str(amount_arr[3])


func _on_slot_entered():
	SignalBus.slot_entered.emit(self)
	activation_sprite.show()


func _on_slot_exited():
	SignalBus.slot_exited.emit(self)
	activation_sprite.hide()
