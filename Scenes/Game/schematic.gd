extends Node2D

@onready var camera : Camera2D = $Camera2D

var node : SchematicsNode = null
var dragging : bool = false

@export var cpu_goal: GoalData
@export var gpu_goal: GoalData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EconomyManager.initialize_game(Constants.STARTING_MONEY)
	GoalManager.call_deferred("activate_single_goal",cpu_goal)
	GoalManager.call_deferred("activate_single_goal",gpu_goal)
	#GoalManager.activate_single_goal(cpu_goal)
	#GoalManager.activate_single_goal(gpu_goal)
	SignalBus.node_entered.connect(_on_node_entered)
	SignalBus.node_exited.connect(_on_node_exited)
	pass # Replace with function body.

func _on_node_entered(n: SchematicsNode) -> void:
	if not dragging:
		node = n
func _on_node_exited(_n: SchematicsNode) -> void:
	if not dragging:
		node = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle camera pan
	var dir : Vector2 = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	var velocity : Vector2 = dir * Constants.CAMERA_PAN_SPEED	
	camera.position += velocity * delta
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if node:
			dragging = true
			node.set_position(get_global_mouse_position() - node.get_center())
	else:
		dragging = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mouse_move: Vector2 = Input.get_last_mouse_velocity()


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
