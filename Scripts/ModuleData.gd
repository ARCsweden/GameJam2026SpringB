extends Resource
class_name ModuleData

@export var module_name: String
@export var cost: int
@export var packed_scene: PackedScene # The actual node to spawn when bought
@export var goal_id_to_trigger: String = ""
@export var action_tag: String = ""
