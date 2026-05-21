extends GridContainer

@export var store_item_scene: PackedScene
# This lets you drag all your .tres modules into the inspector to populate the shop!
@export var available_modules: Array[ModuleData] 

func _ready() -> void:
	for module in available_modules:
		var new_item = store_item_scene.instantiate() as StoreItemUI
		add_child(new_item)
		new_item.setup(module)
