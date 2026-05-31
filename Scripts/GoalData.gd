extends Resource
class_name GoalData

enum LogicType {ACTIVE, PASSIVE}

@export var goal_id: String
@export var description: String
@export var reward_amount: int
@export var next_goals: Array[GoalData]
@export var is_repeatable: bool = false
@export var target_multiplier: float = 1.0 
@export var reward_multiplier: float = 1.0
@export var icon: Texture2D
@export var node_data: NodeData
@export_multiline var goal_text: String
@export var logic_type: LogicType = LogicType.PASSIVE
@export var requirements: Array[GoalRequirement]
