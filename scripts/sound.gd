class_name RiftSound
extends Node
const BUS_NAME := &"RiftEffects"
var bus_index := -1
var arena: Node3D
var streams: Dictionary = {}
var voices: Array[AudioStreamPlayer3D] = []
var cursor := 0
var rng := RandomNumberGenerator.new()
var last_play: Dictionary = {}
func _ready() -> void:
	rng.seed = 771
	bus_index = AudioServer.get_bus_index(BUS_NAME)
	if bus_index < 0:
		AudioServer.add_bus()
		bus_index = AudioServer.bus_count-1
		AudioServer.set_bus_name(bus_index,BUS_NAME)
		AudioServer.set_bus_send(bus_index,&"Master")
	arena.settings.effects_volume_changed.connect(set_effects_volume)
	set_effects_volume(arena.settings.effects_volume)
	for name_value in ["swing","hit","block","cast","step","rune","death","dash","seismic","orb","blink","frost","bolt"]:
		streams[name_value] = load("res://assets/audio/%s.wav" % name_value)
	# Reuse voices; a busy fight cannot create an unbounded number of players.
	for i in 18:
		var voice := AudioStreamPlayer3D.new()
		voice.bus = BUS_NAME
		voice.max_distance = 26
		voice.unit_size = 6
		voice.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		add_child(voice)
		voices.append(voice)
func play(name_value: String,where: Vector3,level: float = 0) -> void:
	# The headless dummy audio driver cannot drain spatial playback queues.
	if DisplayServer.get_name() == "headless" or arena.settings.effects_volume <= 0:
		return
	var now := Time.get_ticks_msec()
	if now-int(last_play.get(name_value,-1000)) < 35:
		return
	last_play[name_value] = now
	var voice := voices[cursor]
	cursor = (cursor+1)%voices.size()
	voice.stop()
	voice.stream = streams[name_value]
	voice.global_position = where
	voice.volume_db = -12+level
	voice.pitch_scale = rng.randf_range(.95,1.05)
	voice.play()

func set_effects_volume(value: float) -> void:
	# A bus applies adjustments to existing playback as well as future sounds, even in pause.
	AudioServer.set_bus_mute(bus_index,value <= 0)
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(maxf(value,.0001)))

func reset() -> void:
	for voice in voices:
		voice.stop()
		voice.stream = null
	last_play.clear()

func _exit_tree() -> void:
	reset()
	streams.clear()
	voices.clear()
