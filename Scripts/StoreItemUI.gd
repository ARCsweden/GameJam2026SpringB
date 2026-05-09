extends PanelContainer
class_name StoreItemUI

var module_data: ModuleData

# Let's pretend you added an @onready var icon = $TextureRect and price_label = $Label

@onready var icon_rect: TextureRect = $VBoxContainer/TextureRect # Adjust path if needed
@onready var price_label: Label = $VBoxContainer/Label 
@onready var item_name: Label = $VBoxContainer/Label2          # Adjust path if needed

func setup(data: ModuleData) -> void:
	module_data = data
	icon_rect.texture = data.icon
	price_label.text = "$" + str(data.cost)
	item_name.text = str(data.module_name)
	# icon.texture = data.icon # (If you add an icon variable to ModuleData later!)
	# price_label.text = "$" + str(data.cost)
# This listens for raw inputs directly on the UI element
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# We only care about the exact moment the mouse goes DOWN
		if event.pressed:
			if EconomyManager.spend_money(module_data.cost):
				# Tell the Schematic to spawn it!
				SignalBus.spawn_from_store.emit(module_data)
				
				# Consume the input so other UI elements don't get confused
				accept_event()
# --- GODOT'S BUILT-IN DRAG FUNCTION ---
# This automatically runs when the user clicks and drags this Control node
#func _get_drag_data(at_position: Vector2) -> Variant:
#	# 1. Create a visual preview that follows the mouse
#	var preview = ColorRect.new() # You could use a Sprite or TextureRect here!
#	preview.color = Color(1, 1, 1, 0.5) # Semi-transparent
#	preview.custom_minimum_size = Vector2(50, 50)
#	set_drag_preview(preview)
	
	# 2. Tell the system exactly WHAT data we are dragging
#	return module_data
