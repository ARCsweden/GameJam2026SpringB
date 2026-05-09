extends Node2D

@onready var camera : Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle camera pan
	var dir : Vector2 = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	var velocity : Vector2 = dir * Constants.CAMERA_PAN_SPEED	
	camera.position += velocity * delta

func _unhandled_input(event: InputEvent) -> void:
	# Handle zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.zoom += Vector2.ONE * Constants.CAMERA_ZOOM_SPEED * get_process_delta_time()
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.zoom -= Vector2.ONE * Constants.CAMERA_ZOOM_SPEED * get_process_delta_time()
			# Clamp zoom
			if camera.zoom.x < Constants.ZOOM_LIMIT_MAX:
				camera.zoom = Vector2.ONE * Constants.ZOOM_LIMIT_MAX
			if camera.zoom.x > Constants.ZOOM_LIMIT_MIN:
				camera.zoom = Vector2.ONE * Constants.ZOOM_LIMIT_MIN
