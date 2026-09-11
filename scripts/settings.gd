class_name TrainingSettings
extends Resource

signal effects_volume_changed(value: float)

# Camera and input preferences; hero statistics are defined in RiftRules.
@export var camera_distance: float = 6.5

@export var camera_follow_speed: float = 14.0
@export var mouse_sensitivity: float = .0024
@export var effects_volume: float = 0.65:
	set(value):
		if not is_finite(value): return
		effects_volume = clampf(value,0,1)
		effects_volume_changed.emit(effects_volume)
@export var acceleration_rate: float = 70.0
@export var stopping_rate: float = 90.0
@export var input_buffer_window: float = 0.12

const PREFERENCES_PATH := "user://survival-preferences.cfg"
const PREFERENCE_LIMITS := {
	"camera_follow_speed": Vector2(4.0,16.0),
	"camera_distance": Vector2(3.5,8.0),
	"mouse_sensitivity": Vector2(.0008,.004),
	"effects_volume": Vector2(0.0,1.0),
}

func load_preferences(path: String = PREFERENCES_PATH) -> Error:
	var config := ConfigFile.new()
	var error := config.load(path)
	if error != OK:
		return error
	for key in PREFERENCE_LIMITS:
		var value = config.get_value("preferences",key,get(key))
		if (value is float or value is int) and is_finite(float(value)):
			var limits: Vector2 = PREFERENCE_LIMITS[key]
			set(key,clampf(float(value),limits.x,limits.y))
	return OK

func save_preferences(path: String = PREFERENCES_PATH) -> Error:
	var config := ConfigFile.new()
	for key in PREFERENCE_LIMITS:
		config.set_value("preferences",key,get(key))
	return config.save(path)

static func register_movement_actions() -> void:
	var bindings := {"move_left":KEY_A,"move_right":KEY_D,"move_forward":KEY_W,"move_back":KEY_S}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.physical_keycode = bindings[action]
			InputMap.action_add_event(action,event)
