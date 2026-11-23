extends Node2D

@export_file("*.tscn") var next_level = ""
@export_enum("Kamp", "Finn haglen", "Hent lagerlisten") var objective = 0
@export var chapter = ""
@export_multiline var briefing = ""
var supplies_collected = false

@onready var hud = $GameHUD
@onready var waves = get_node_or_null("WaveManager")
var completed = false

func _process(_delta: float) -> void:
	if completed or hud.game_over or hud.changing_scene: return
	update_objective()
	if waves and not waves.finished: return
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.dead: return
	if not objective_ready(): return
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

func objective_ready() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if objective == 1: return player != null and player.has_shotgun
	if objective == 2: return supplies_collected
	return true

func update_objective() -> void:
	var enemies_left = 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.dead: enemies_left += 1
	var task = "Slå bossen og vaktene. Frigjør sprøytene."
	if objective == 1: task = "Finn haglen." if not objective_ready() else "Hold området til siste vakt er slått."
	if objective == 2: task = "Hent lagerlisten øst på plassen." if not supplies_collected else "Lagerlisten er sikret. Slå de siste vaktene."
	hud.get_node("Screen/Objective/Content/Title").text = chapter
	hud.get_node("Screen/Objective/Content/Goal").text = task + "  |  Fiender: %d" % enemies_left
	hud.get_node("Screen/Objective/Content/Story").text = briefing
