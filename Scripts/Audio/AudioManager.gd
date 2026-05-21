extends Node

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const MASTER_BUS := "Master"

const SOUNDS := {
	"node_press": preload("res://Assets/Audio/SFX/Node_Click.ogg"),
	"connection_valid": preload("res://Assets/Audio/SFX/Node_Valid.ogg"),
	"connection_invalid": preload("res://Assets/Audio/SFX/Node_Error.ogg"),
	"connection_cancelled": preload("res://Assets/Audio/SFX/Node_Cancelled.ogg"),
	"purchase": preload("res://Assets/Audio/SFX/Purchase.mp3"),
	"goal": preload("res://Assets/Audio/SFX/Victory_Fanfare.ogg")
}

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_pool: Array[Node] = $SFXPool.get_children()
@onready var audio_debug: Node = $AudioDebug

var current_music_name: String = ""
var current_music_path: String = ""


func _ready() -> void:
	audio_debug.startup_report(self)

	await get_tree().process_frame

	_connect_signals()

	play_music("Main_Theme")


func _connect_signals() -> void:
	if not SignalBus.spawn_from_store.is_connected(_on_item_bought):
		SignalBus.spawn_from_store.connect(_on_item_bought)

	if not SignalBus.audio_sfx_requested.is_connected(_on_audio_sfx_requested):
		SignalBus.audio_sfx_requested.connect(_on_audio_sfx_requested)

	if not GoalManager.goal_completed.is_connected(_on_goal_completed):
		GoalManager.goal_completed.connect(_on_goal_completed)
		
	

	audio_debug.signals_connected_report()

# Callstack for the SFX
func _on_item_bought(_module_data: ModuleData) -> void:
	play_sfx("purchase")

func _on_audio_sfx_requested(sound_name: String) -> void:
	play_sfx(sound_name)

func _on_goal_completed(_goal_id: String) -> void:
	play_sfx("goal")

func play_music(music_name: String) -> void:
	var music_path: String = "res://Assets/Audio/Music/%s.ogg" % music_name

	if not audio_debug.validate_bus_exists(MUSIC_BUS):
		push_warning("Music bus '%s' does not exist. AudioStreamPlayer may fall back to Master." % MUSIC_BUS)

	var stream: AudioStream = load(music_path)

	if stream == null:
		audio_debug.music_load_failed(music_name, music_path)
		return

	if music_player.stream == stream and music_player.playing:
		audio_debug.music_request_ignored(music_name, music_path)
		return

	music_player.bus = MUSIC_BUS
	music_player.stream = stream
	music_player.play()

	current_music_name = music_name
	current_music_path = music_path

	audio_debug.music_started(self, music_name, music_path)


func stop_music() -> void:
	if not music_player.playing:
		audio_debug.music_stop_ignored(self)
		return

	music_player.stop()

	audio_debug.music_stopped(self)

	current_music_name = ""
	current_music_path = ""


func play_sfx(sound_name: String) -> void:
	if not audio_debug.validate_bus_exists(SFX_BUS):
		push_warning("SFX bus '%s' does not exist. AudioStreamPlayer may fall back to Master." % SFX_BUS)

	if not SOUNDS.has(sound_name):
		audio_debug.sfx_not_found(sound_name, SOUNDS)
		return

	var stream: AudioStream = SOUNDS[sound_name]
	var selected_player: AudioStreamPlayer = null
	var selected_index: int = -1
	var pool_was_full: bool = false

	for i in range(sfx_pool.size()):
		var player: AudioStreamPlayer = sfx_pool[i] as AudioStreamPlayer

		if player == null:
			audio_debug.invalid_sfx_pool_child(i, sfx_pool[i])
			continue

		if not player.playing:
			selected_player = player
			selected_index = i
			break

	if selected_player == null:
		pool_was_full = true

		for i in range(sfx_pool.size()):
			var fallback_player: AudioStreamPlayer = sfx_pool[i] as AudioStreamPlayer

			if fallback_player != null:
				selected_player = fallback_player
				selected_index = i
				break

	if selected_player == null:
		audio_debug.no_valid_sfx_player()
		return

	selected_player.bus = SFX_BUS
	selected_player.stream = stream
	selected_player.pitch_scale = randf_range(0.9, 1.1)
	selected_player.play()

	audio_debug.sfx_started(sound_name, stream, selected_player, selected_index, pool_was_full)


func set_bus_volume_linear(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		audio_debug.bus_volume_change_failed(bus_name)
		return

	var clamped_value: float = clampf(value, 0.0, 1.0)

	if clamped_value <= 0.0:
		AudioServer.set_bus_mute(bus_index, true)
		audio_debug.bus_muted(bus_name)
		return

	AudioServer.set_bus_mute(bus_index, false)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamped_value))

	audio_debug.bus_volume_changed(bus_name, clamped_value, AudioServer.get_bus_volume_db(bus_index))


func set_bus_mute(bus_name: String, is_muted: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		audio_debug.bus_mute_change_failed(bus_name)
		return

	AudioServer.set_bus_mute(bus_index, is_muted)

	audio_debug.bus_mute_changed(bus_name, AudioServer.is_bus_mute(bus_index))


func debug_audio_now() -> void:
	audio_debug.manual_report(self)
