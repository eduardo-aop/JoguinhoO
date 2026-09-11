extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var arena: RiftArena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	arena.start_round("warrior",true)
	for fighter in arena.fighters: fighter.set_physics_process(false)
	for i in 8: await get_tree().process_frame
	var original_volume: float = arena.settings.effects_volume
	arena.settings.effects_volume = .2
	arena.sound.play("frost",arena.player.position)
	for i in 2: await get_tree().process_frame
	var voice: AudioStreamPlayer3D = arena.sound.voices[0]
	var started := voice.playing and voice.stream != null and voice.bus == RiftSound.BUS_NAME
	arena.hud.pause_game()
	arena.settings.effects_volume = 0
	var muted := AudioServer.is_bus_mute(arena.sound.bus_index)
	arena.settings.effects_volume = .35
	var gain := voice.volume_db+AudioServer.get_bus_volume_db(arena.sound.bus_index)
	var adjusted := not AudioServer.is_bus_mute(arena.sound.bus_index) and is_equal_approx(gain,-12+linear_to_db(.35))
	var report := {"native_audio_started":started,"voice_bus":str(voice.bus),"voice_playing":voice.playing,"stream_loaded":voice.stream != null,"muted_during_pause":muted,"existing_voice_gain_adjusted":adjusted,"passed":started and muted and adjusted}
	var file := FileAccess.open("res://docs/AUDIO-VOLUME-V5.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	arena.settings.effects_volume = original_volume
	print("AUDIO_VOLUME_PREVIEW_COMPLETE ",JSON.stringify(report))
	if not report.passed: push_error("Audio volume routing failed")
