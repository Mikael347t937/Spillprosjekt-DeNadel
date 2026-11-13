
extends Node2D

@export var enemy_scene: PackedScene
@export var player: Node2D

@export var max_waves: int = 2

@export var spawn_distance: float = 500.0
@export var spawn_delay: float = 0.7
@export var pause_between_waves: float = 3.0

@export var first_wave_enemies: int = 5
@export var increase_per_wave: int = 2

var finished = false
var current_wave: int = 0
var enemies_alive: int = 0
var is_spawning: bool = false
var waiting_for_next_wave: bool = false


func _ready() -> void:
	if enemy_scene == null or player == null:
		push_error("Mangler Enemy Scene eller Player!")
		return

	start_wave.call_deferred()


func start_wave() -> void:
	if not is_inside_tree() or get_parent().is_queued_for_deletion():
		return
	current_wave += 1
	is_spawning = true

	var amount = first_wave_enemies + (current_wave - 1) * increase_per_wave

	print("Wave ", current_wave, " starter!")

	for i in range(amount):
		spawn_enemy()
		await get_tree().create_timer(spawn_delay, false).timeout
		if not is_inside_tree() or get_parent().is_queued_for_deletion():
			return

	is_spawning = false
	check_wave_finished()


func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate() as Node2D

	if enemy == null:
		push_error("Enemy-scenen må ha en Node2D som rot!")
		return

	var angle = randf_range(0.0, TAU)
	var direction = Vector2.RIGHT.rotated(angle)

	enemy.appearance = randi_range(0, 2)
	enemy.position = player.position + direction * spawn_distance
	get_parent().add_child(enemy)

	enemies_alive += 1
	enemy.tree_exited.connect(on_enemy_removed)


func on_enemy_removed() -> void:
	if not is_inside_tree() or get_parent().is_queued_for_deletion():
		return
	enemies_alive -= 1
	check_wave_finished()


func check_wave_finished() -> void:
	if finished or is_spawning or waiting_for_next_wave or enemies_alive > 0:
		return

	if current_wave >= max_waves:
		finished = true
		return

	waiting_for_next_wave = true

	print("Wave ", current_wave, " fullført!")

	await get_tree().create_timer(pause_between_waves, false).timeout
	if not is_inside_tree() or get_parent().is_queued_for_deletion():
		return

	waiting_for_next_wave = false
	start_wave()
	
