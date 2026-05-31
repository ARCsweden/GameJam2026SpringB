extends Control
class_name MoneyChangeFx

@onready var label : Label = $Label
@onready var anim_player : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.connect("animation_finished", _on_animation_finished)
	anim_player.play("fade")


func update_money(amount: int) -> void:
	if amount > 0:
		label.text = "+$" + str(amount)
		modulate = Color.GREEN
	else:
		label.text = "-$" + str(amount)
		modulate = Color.RED


func _on_animation_finished(_name: String) -> void:
	queue_free()
