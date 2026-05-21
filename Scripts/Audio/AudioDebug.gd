extends Node

@export var debug_audio: bool = true

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const MASTER_BUS := "Master"


func startup_report(audio_manager: Node) -> void:
	debug_header("AUDIO MANAGER READY")

	debug_log("AudioManager instance path: %s" % audio_manager.get_path())

	if audio_manager.music_player != null:
		debug_log("MusicPlayer path: %s" % audio_manager.music_player.get_path())
	else:
		push_error("MusicPlayer is missing.")

	if audio_manager.has_node("SFXPool"):
		debug_log("SFXPool path: %s" % audio_manager.get_node("SFXPool").get_path())
	else:
		push_error("SFXPool is missing.")

	debug_log("SFX pool size: %d" % audio_manager.sfx_pool.size())

	validate_audio_setup(audio_manager)
	print_audio_buses()
	print_music_status(audio_manager)
	print_sfx_pool_status(audio_manager)
	print_available_sounds(audio_manager.SOUNDS)


func signals_connected_report() -> void:
	debug_header("AUDIO SIGNALS")
	debug_log("Connected: SignalBus.spawn_from_store -> _on_item_bought")
	debug_log("Connected: SignalBus.click_output -> _on_ui_click")
	debug_log("Connected: GoalManager.goal_completed -> _on_goal_completed")


func validate_audio_setup(audio_manager: Node) -> void:
	debug_header("VALIDATING AUDIO SETUP")

	if audio_manager.music_player == null:
		push_error("MusicPlayer node is missing.")
	else:
		debug_log("MusicPlayer found: %s" % audio_manager.music_player.get_path())

	if not audio_manager.has_node("SFXPool"):
		push_error("SFXPool node is missing.")
	else:
		debug_log("SFXPool found: %s" % audio_manager.get_node("SFXPool").get_path())

	if audio_manager.sfx_pool.is_empty():
		push_warning("SFX pool is empty. No SFX can be played.")
	else:
		debug_log("SFX pool contains %d children." % audio_manager.sfx_pool.size())

	for i in range(audio_manager.sfx_pool.size()):
		var player: AudioStreamPlayer = audio_manager.sfx_pool[i] as AudioStreamPlayer

		if player == null:
			push_warning("SFXPool child at index %d is not an AudioStreamPlayer: %s" % [i, str(audio_manager.sfx_pool[i])])
		else:
			debug_log("SFX player %d valid: %s" % [i, player.get_path()])

	validate_bus_exists(MASTER_BUS)
	validate_bus_exists(MUSIC_BUS)
	validate_bus_exists(SFX_BUS)


func validate_bus_exists(bus_name: String) -> bool:
	var index: int = AudioServer.get_bus_index(bus_name)

	if index == -1:
		push_warning("Audio bus not found: " + bus_name)
		return false

	debug_log("Audio bus found: %s at index %d" % [bus_name, index])
	return true


func print_audio_buses() -> void:
	debug_header("AUDIO BUSES AT STARTUP")
	debug_log("Bus count: %d" % AudioServer.bus_count)

	for i in range(AudioServer.bus_count):
		var bus_name: String = AudioServer.get_bus_name(i)
		var send_name: String = AudioServer.get_bus_send(i)
		var effect_count: int = AudioServer.get_bus_effect_count(i)

		debug_log(
			"Bus %d | name: %s | volume dB: %.2f | muted: %s | solo: %s | bypass effects: %s | send: %s | effects: %d"
			% [
				i,
				bus_name,
				AudioServer.get_bus_volume_db(i),
				str(AudioServer.is_bus_mute(i)),
				str(AudioServer.is_bus_solo(i)),
				str(AudioServer.is_bus_bypassing_effects(i)),
				send_name,
				effect_count
			]
		)

		for effect_index in range(effect_count):
			var effect: AudioEffect = AudioServer.get_bus_effect(i, effect_index)
			var enabled: bool = AudioServer.is_bus_effect_enabled(i, effect_index)

			debug_log(
				"  Effect %d | enabled: %s | type: %s"
				% [
					effect_index,
					str(enabled),
					effect.get_class()
				]
			)

	debug_log("Master index: %d" % AudioServer.get_bus_index(MASTER_BUS))
	debug_log("Music index: %d" % AudioServer.get_bus_index(MUSIC_BUS))
	debug_log("SFX index: %d" % AudioServer.get_bus_index(SFX_BUS))


func print_music_status(audio_manager: Node) -> void:
	debug_header("MUSIC STATUS AT STARTUP")

	var music_player: AudioStreamPlayer = audio_manager.music_player

	if music_player == null:
		debug_log("MusicPlayer missing.")
		return

	debug_log("Current music name: %s" % audio_manager.current_music_name)
	debug_log("Current music path: %s" % audio_manager.current_music_path)
	debug_log("MusicPlayer path: %s" % music_player.get_path())
	debug_log("MusicPlayer playing: %s" % str(music_player.playing))
	debug_log("MusicPlayer stream assigned: %s" % str(music_player.stream != null))
	debug_log("MusicPlayer stream path: %s" % get_stream_path(music_player.stream))
	debug_log("MusicPlayer bus: %s" % music_player.bus)
	debug_log("MusicPlayer bus index: %d" % AudioServer.get_bus_index(music_player.bus))
	debug_log("MusicPlayer volume dB: %.2f" % music_player.volume_db)
	debug_log("MusicPlayer pitch scale: %.2f" % music_player.pitch_scale)
	debug_log("MusicPlayer autoplay: %s" % str(music_player.autoplay))
	debug_log("MusicPlayer max polyphony: %d" % music_player.max_polyphony)

	if music_player.bus != MUSIC_BUS:
		push_warning("MusicPlayer bus is '%s', expected '%s'." % [music_player.bus, MUSIC_BUS])


func print_sfx_pool_status(audio_manager: Node) -> void:
	debug_header("SFX POOL STATUS AT STARTUP")
	debug_log("SFX pool size: %d" % audio_manager.sfx_pool.size())

	var active_count: int = 0

	for i in range(audio_manager.sfx_pool.size()):
		var player: AudioStreamPlayer = audio_manager.sfx_pool[i] as AudioStreamPlayer

		if player == null:
			debug_log("SFX player %d: INVALID NODE" % i)
			continue

		if player.playing:
			active_count += 1

		debug_log(
			"SFX player %d | path: %s | playing: %s | bus: %s | bus index: %d | stream: %s | volume dB: %.2f | pitch: %.2f"
			% [
				i,
				player.get_path(),
				str(player.playing),
				player.bus,
				AudioServer.get_bus_index(player.bus),
				get_stream_path(player.stream),
				player.volume_db,
				player.pitch_scale
			]
		)

	debug_log("Active SFX players: %d/%d" % [active_count, audio_manager.sfx_pool.size()])


func print_available_sounds(sounds: Dictionary) -> void:
	debug_header("AVAILABLE SFX")
	debug_log("SOUNDS dictionary size: %d" % sounds.size())

	for sound_name in sounds.keys():
		var stream: AudioStream = sounds[sound_name]
		debug_log("SFX key: %s | stream path: %s" % [sound_name, get_stream_path(stream)])


func music_started(audio_manager: Node, music_name: String, music_path: String) -> void:
	debug_header("MUSIC STARTED")

	var music_player: AudioStreamPlayer = audio_manager.music_player

	debug_log("Music name: %s" % music_name)
	debug_log("Playing music: %s" % music_path)
	debug_log("Music player path: %s" % music_player.get_path())
	debug_log("Music player bus: %s" % music_player.bus)
	debug_log("Music player bus index: %d" % AudioServer.get_bus_index(music_player.bus))
	debug_log("Music player playing: %s" % str(music_player.playing))
	debug_log("Music stream resource path: %s" % get_stream_path(music_player.stream))
	debug_log("Music volume dB: %.2f" % music_player.volume_db)
	debug_log("Music pitch scale: %.2f" % music_player.pitch_scale)


func music_load_failed(music_name: String, music_path: String) -> void:
	debug_header("MUSIC LOAD FAILED")
	push_warning("Music file not found or failed to load.")
	debug_log("Music name: %s" % music_name)
	debug_log("Music path: %s" % music_path)


func music_request_ignored(music_name: String, music_path: String) -> void:
	debug_header("PLAY MUSIC REQUEST IGNORED")
	debug_log("Music already playing.")
	debug_log("Music name: %s" % music_name)
	debug_log("Music path: %s" % music_path)


func music_stop_ignored(audio_manager: Node) -> void:
	debug_header("STOP MUSIC REQUEST IGNORED")
	debug_log("Music was not playing.")
	print_music_status(audio_manager)


func music_stopped(audio_manager: Node) -> void:
	debug_header("MUSIC STOPPED")
	debug_log("Stopped music: %s" % audio_manager.current_music_path)
	debug_log("Music player playing: %s" % str(audio_manager.music_player.playing))


func sfx_started(
	sound_name: String,
	stream: AudioStream,
	selected_player: AudioStreamPlayer,
	selected_index: int,
	pool_was_full: bool
) -> void:
	debug_header("SFX STARTED")
	debug_log("Playing SFX: %s" % sound_name)
	debug_log("SFX stream resource path: %s" % get_stream_path(stream))
	debug_log("SFX player index: %d" % selected_index)
	debug_log("SFX player path: %s" % selected_player.get_path())
	debug_log("SFX player bus: %s" % selected_player.bus)
	debug_log("SFX player bus index: %d" % AudioServer.get_bus_index(selected_player.bus))
	debug_log("SFX player playing: %s" % str(selected_player.playing))
	debug_log("SFX volume dB: %.2f" % selected_player.volume_db)
	debug_log("SFX pitch scale: %.2f" % selected_player.pitch_scale)
	debug_log("SFX pool was full: %s" % str(pool_was_full))


func sfx_not_found(sound_name: String, sounds: Dictionary) -> void:
	debug_header("SFX NOT FOUND")
	push_warning("Sound '%s' not found in SOUNDS dictionary!" % sound_name)
	print_available_sounds(sounds)


func invalid_sfx_pool_child(index: int, child: Node) -> void:
	debug_header("INVALID SFX POOL CHILD")
	push_warning("SFX pool child at index %d is not an AudioStreamPlayer: %s" % [index, str(child)])


func no_valid_sfx_player() -> void:
	debug_header("NO VALID SFX PLAYER")
	push_warning("No valid AudioStreamPlayer found in SFX pool. Cannot play SFX.")


func bus_volume_change_failed(bus_name: String) -> void:
	debug_header("BUS VOLUME CHANGE FAILED")
	push_warning("Cannot set volume. Audio bus not found: " + bus_name)


func bus_mute_change_failed(bus_name: String) -> void:
	debug_header("BUS MUTE CHANGE FAILED")
	push_warning("Cannot mute. Audio bus not found: " + bus_name)


func bus_muted(bus_name: String) -> void:
	debug_header("BUS MUTED")
	debug_log("Bus muted: %s" % bus_name)


func bus_volume_changed(bus_name: String, linear_value: float, volume_db: float) -> void:
	debug_header("BUS VOLUME CHANGED")
	debug_log("Bus: %s" % bus_name)
	debug_log("Linear value: %.2f" % linear_value)
	debug_log("Volume dB: %.2f" % volume_db)


func bus_mute_changed(bus_name: String, is_muted: bool) -> void:
	debug_header("BUS MUTE CHANGED")
	debug_log("Bus: %s" % bus_name)
	debug_log("Muted: %s" % str(is_muted))


func manual_report(audio_manager: Node) -> void:
	debug_header("MANUAL AUDIO DEBUG")
	print_audio_buses()
	print_music_status(audio_manager)
	print_sfx_pool_status(audio_manager)
	print_active_bus_usage_summary(audio_manager)


func print_active_bus_usage_summary(audio_manager: Node) -> void:
	debug_header("ACTIVE BUS USAGE SUMMARY")

	var usage: Dictionary = {}

	for i in range(AudioServer.bus_count):
		var bus_name: String = AudioServer.get_bus_name(i)
		usage[bus_name] = []

	if audio_manager.music_player != null:
		var music_player: AudioStreamPlayer = audio_manager.music_player

		var music_info: String = "MusicPlayer playing=%s stream=%s" % [
			str(music_player.playing),
			get_stream_path(music_player.stream)
		]

		if usage.has(music_player.bus):
			usage[music_player.bus].append(music_info)
		else:
			usage[music_player.bus] = [music_info]

	for i in range(audio_manager.sfx_pool.size()):
		var player: AudioStreamPlayer = audio_manager.sfx_pool[i] as AudioStreamPlayer

		if player == null:
			continue

		var sfx_info: String = "%s playing=%s stream=%s" % [
			player.name,
			str(player.playing),
			get_stream_path(player.stream)
		]

		if usage.has(player.bus):
			usage[player.bus].append(sfx_info)
		else:
			usage[player.bus] = [sfx_info]

	for bus_name in usage.keys():
		debug_log("Bus: %s" % bus_name)

		if usage[bus_name].is_empty():
			debug_log("  No known AudioStreamPlayers assigned.")
		else:
			for item in usage[bus_name]:
				debug_log("  %s" % item)


func get_stream_path(stream: AudioStream) -> String:
	if stream == null:
		return "<empty>"

	if stream.resource_path == "":
		return "<runtime/generated stream>"

	return stream.resource_path


func debug_log(message: String) -> void:
	if not debug_audio:
		return

	print(message)


func debug_header(title: String) -> void:
	if not debug_audio:
		return

	print("")
	print("========== %s ==========" % title)
