extends Node2D

@export_file("*.tscn") var next_level = ""
@onready var hud = $GameHUD
@onready var waves = get_node_or_null("WaveManager")
var completed = false

func _process(_delta: float) -> void:
	if completed or hud.game_over or hud.changing_scene: return
	if waves and not waves.finished: return
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.dead: return
	completed = true
	hud.show_victory(next_level)
