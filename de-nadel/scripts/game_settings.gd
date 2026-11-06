extends Node

signal changed
const DEFAULT_CONFIG_PATH = "user://settings.cfg"
var config_path = DEFAULT_CONFIG_PATH
var volume = 0.65
var fullscreen = false
var reduced_motion = false

func _ready() -> void:
	load_settings()
	apply_settings()

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(config_path) == OK:
		volume = clampf(float(config.get_value("audio", "volume", 0.65)), 0, 1)
		fullscreen = bool(config.get_value("display", "fullscreen", false))
		reduced_motion = bool(config.get_value("display", "reduced_motion", false))

func save_settings() -> Error:
	var config = ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "reduced_motion", reduced_motion)
	return config.save(config_path)

func apply_settings() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(0, volume <= 0.001)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	changed.emit()
