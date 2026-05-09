extends Resource
class_name GoalData

@export var goal_id: String
@export var description: String
@export var reward_amount: int
@export var target_value: int
@export var next_goals: Array[GoalData]
@export var is_repeatable: bool = false
@export var action_tag: String
@export var target_multiplier: float = 1.0 
@export var reward_multiplier: float = 1.0
@export var icon: Texture2D
@export var packed_scene: PackedScene
@export var goal_text: String
#@export var amount_of_CPU: int
#@export var amount_of_GPU: int
#@export var amount_of_cameras: int # e.g., "Connect 5 pipes" -> target_value = 5
#@export var camera_resolution_target: int
#@export var camera_speed_target: int
#@export var amount_of_arms: int
#@export var amount_of_legs: int
#@export var amount_of_monitors: int
