extends Node

# Dict with sounds 
const SOUNDS = {
	"error": preload("res://Assets/Audio/SFX/Node_Error.ogg"),
	"click": preload("res://Assets/Audio/SFX/UI_Click.ogg")
	
}

@onready var music_player = $MusicPlayer
@onready var sfx_pool = $SFXPool.get_children()

func _ready() -> void:
	
	SignalBus.spawn_from_store.connect(_on_item_bought)
	SignalBus.click_output.connect(_on_ui_click)
	GoalManager.goal_completed.connect(_on_goal_completed)
	print("Test")
	play_music("Main_Theme")
	
# Callbacks
func _on_item_bought(_module_data: ModuleData):
	play_sfx("buy")

func _on_ui_click(_object):
	play_sfx("click")

func _on_goal_completed(_goal_id: String):
	play_sfx("goal_win")

# Function to play sfx
func play_sfx(sound_name: String):
	if not SOUNDS.has(sound_name):
		print("Warning: Sound '" + sound_name + "' not found!")
		return

	var stream = SOUNDS[sound_name]
	
	# Find available player in pool
	for player in sfx_pool:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = randf_range(0.9, 1.1)
			player.play()
			return
	
	# If pool is full, force first to resart
	sfx_pool[0].stream = stream
	sfx_pool[0].play()

# Function to change music. Even though there is only on song... for now
func play_music(music_name: String):
	
	var music_path = "res://Assets/Audio/Music/Main_Theme.ogg"
	var stream = load(music_path)
	
	if music_player.stream == stream:
		return
		
	music_player.stream = stream
	music_player.play()
