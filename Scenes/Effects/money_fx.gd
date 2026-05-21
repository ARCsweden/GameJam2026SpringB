extends Node2D


@onready var particles : GPUParticles2D = $GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particles.emitting = true
	particles.finished.connect(_on_finished)


func _on_finished() -> void:
	queue_free()
