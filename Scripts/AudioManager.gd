extends Node

# Dict with sounds 
const SOUNDS = {
	"Error": preload("res://Assets/Audio/SFX/Node_Error.ogg"),
	
}

@onready var music_player = $MusicPlayer
@onready var sfx_pool = $SFXPool.get_children()

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
