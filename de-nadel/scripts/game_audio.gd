extends Node

@onready var PISTOL: AudioStream = load("res://assets/audio/pistol.wav")
@onready var SHOTGUN: AudioStream = load("res://assets/audio/shotgun.wav")
@onready var IMPACT: AudioStream = load("res://assets/audio/impact.wav")
@onready var PICKUP: AudioStream = load("res://assets/audio/pickup.wav")

func play_effect(stream: AudioStream, volume_db: float = -8.0) -> void:
	if get_tree().paused or DisplayServer.get_name() == "headless": return
	var voice = AudioStreamPlayer.new()
	voice.stream = stream
	voice.volume_db = volume_db
	voice.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(voice)
	voice.finished.connect(voice.queue_free)
	voice.play()

func _exit_tree() -> void:
	for voice in get_children():
		voice.stop()
		voice.stream = null
