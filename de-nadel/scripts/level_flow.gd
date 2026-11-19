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
	finish_level()

func finish_level() -> void:
	var cages = get_tree().get_nodes_in_group("supply_cages")
	if not cages.is_empty():
		hud.ending = true
		get_tree().get_first_node_in_group("player").begin_ending()
		for projectile in get_tree().get_nodes_in_group("enemy_projectiles"): projectile.queue_free()
		for cage in cages:
			await cage.release_supplies()
			if not is_inside_tree(): return
		if not is_inside_tree(): return
	hud.show_victory(next_level, not cages.is_empty())
