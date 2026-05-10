extends Node2D

@onready var camera : Camera2D = $Camera2D

# We only need ONE variable now! It will hold either a regular module or a goal.
var node : SchematicsNode = null 
var dragging : bool = false

@export var cpu_goal: GoalData
@export var gpu_goal: GoalData
@export var buy_compute_repeat: GoalData
@export var buy_motion_repeat: GoalData
@export var buy_power_repeat: GoalData
@export var buy_vision_repeat: GoalData
@export var compute_repeat: GoalData
@export var motion_repeat: GoalData
@export var power_repeat: GoalData
@export var vision_repeat: GoalData


func _ready() -> void:
	EconomyManager.initialize_game(Constants.STARTING_MONEY)
	#GoalManager.call_deferred("activate_single_goal",cpu_goal)
	#GoalManager.call_deferred("activate_single_goal",gpu_goal)
	GoalManager.call_deferred("unlock_goal_for_store",buy_compute_repeat)
	GoalManager.call_deferred("unlock_goal_for_store",buy_motion_repeat)
	GoalManager.call_deferred("unlock_goal_for_store",buy_power_repeat)
	GoalManager.call_deferred("unlock_goal_for_store",buy_vision_repeat)
	GoalManager.call_deferred("unlock_goal_for_store",compute_repeat)
	GoalManager.call_deferred("unlock_goal_for_store",motion_repeat)
	GoalManager.call_deferred("unlock_goal_for_store",power_repeat)
	GoalManager.call_deferred("unlock_goal_for_store",vision_repeat)
	#GoalManager.call_deferred("unlock_goal_for_store",cpu_goal)
	#GoalManager.call_deferred("unlock_goal_for_store",gpu_goal)
	#GoalManager.call_deferred("unlock_goal_for_store",comp_goal)
	#GoalManager.unlock_goal_for_store(cpu_goal)
	#GoalManager.unlock_goal_for_store(gpu_goal)
	

	SignalBus.node_entered.connect(_on_node_entered)
	SignalBus.node_exited.connect(_on_node_exited)
	SignalBus.spawn_from_store.connect(_on_spawn_from_store)
	SignalBus.spawn_goal_from_store.connect(_on_spawn_goal_from_store)
	SignalBus.spawn_goal_done_effect.connect(_on_spawn_goal_done_effect)

func _on_spawn_goal_done_effect(pos: Vector2) -> void:
	var goal_fx = preload("res://Scenes/Game/money_fx.tscn")
	var fx: Node2D = goal_fx.instantiate()
	add_child(fx)
	fx.global_position = pos

# --- Spawn the Goal Node ---
func _on_spawn_goal_from_store(goal: GoalData) -> void:
	# 1. Instantiate it and cast it as a SchematicsNode!
	var new_goal_node = goal.packed_scene.instantiate() as SchematicsNode
	add_child(new_goal_node)
	
	# 2. Pass the data to the node
	if new_goal_node.has_method("setup"):
		new_goal_node.setup(goal)
	
	# 3. Snap to mouse
	new_goal_node.set_position(get_global_mouse_position() - new_goal_node.get_center())
	
	# 4. Hijack the master node variable!
	node = new_goal_node
	dragging = true
	GoalManager.activate_single_goal(goal)
	
# --- Spawn the Regular Node ---
func _on_spawn_from_store(module: ModuleData) -> void:
	var new_node = module.packed_scene.instantiate() as SchematicsNode
	add_child(new_node)
	
	new_node.set_position(get_global_mouse_position() - new_node.get_center())
	
	node = new_node
	dragging = true
	
	if module.action_tag != "":
		GoalManager.trigger_action(module.action_tag, 1)

# --- Drag Detection ---
func _on_node_entered(n: SchematicsNode) -> void:
	if not dragging:
		node = n

func _on_node_exited(_n: SchematicsNode) -> void:
	if not dragging:
		node = null

# --- The unified Drag Loop ---
func _process(delta: float) -> void:
	var dir : Vector2 = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	var velocity : Vector2 = dir * Constants.CAMERA_PAN_SPEED    
	camera.position += velocity * delta
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Because both modules and goals are assigned to "node", 
		# this single block of code now flawlessly drags both of them!
		if node:
			dragging = true
			node.set_position(get_global_mouse_position() - node.get_center())
	else:
		dragging = false

func _unhandled_input(event: InputEvent) -> void:
	# Handle zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera.zoom += Vector2.ONE * Constants.CAMERA_ZOOM_SPEED * get_process_delta_time()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera.zoom -= Vector2.ONE * Constants.CAMERA_ZOOM_SPEED * get_process_delta_time()
			# Clamp zoom
			if camera.zoom.x < Constants.ZOOM_LIMIT_MAX:
				camera.zoom = Vector2.ONE * Constants.ZOOM_LIMIT_MAX
			if camera.zoom.x > Constants.ZOOM_LIMIT_MIN:
				camera.zoom = Vector2.ONE * Constants.ZOOM_LIMIT_MIN

	# Handle right-click panning
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			camera.position -= event.relative
