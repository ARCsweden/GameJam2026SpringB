extends Node2D

@onready var area2d : Area2D = $Area2D
@onready var activation_sprite : Sprite2D = $ActivationSprite


func _on_slot_entered():
	activation_sprite.show()

func _on_slot_exited():
	activation_sprite.hide()
