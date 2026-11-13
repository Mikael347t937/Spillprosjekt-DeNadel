extends SceneTree

var checks = 0
var failures = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition: print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func run() -> void:
	root.size = Vector2i(1600, 900)
	for number in [2, 3]:
		change_scene_to_file("res://scenes/level_select.tscn")
		await process_frame
		await process_frame
		current_scene.get_node("Panel/Content/Level%d" % number).pressed.emit()
		await process_frame
		await process_frame
		var path = "res://Level-%d.tscn" % number
		check(current_scene.scene_file_path == path, "selector opens level %d" % number)
		var player = get_first_node_in_group("player")
		var enemies = get_nodes_in_group("enemies")
		check(enemies.size() == number + 1, "level %d has its own enemy layout" % number)
		check(player.health == 100, "level %d starts with full health" % number)
		for enemy in enemies:
			enemy.set_physics_process(false)
			check(enemy.health == enemy.max_health, "enemy starts with full health")
			check(enemy.position.distance_to(player.position) > 150, "enemy starts away from player")
		await physics_frame
		await process_frame
		check(not player.test_move(player.global_transform, Vector2.ONE), "player spawn is clear")
		for enemy in enemies:
			check(not enemy.test_move(enemy.global_transform, Vector2.ONE), "enemy spawn is clear")
		var before: Vector2 = player.position
		Input.action_press("move_right")
		await create_timer(0.2).timeout
		Input.action_release("move_right")
		check(player.position.x > before.x + 2, "player can move in level %d" % number)
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
		var barrel = player.get_node("Node2D")
		barrel.shoot()
		await process_frame
		var bullets = 0
		for child in current_scene.get_children():
			if child is RigidBody2D: bullets += 1
		check(bullets > 0, "shooting works in level %d" % number)
		if OS.get_cmdline_user_args().has("--capture"):
			await RenderingServer.frame_post_draw
			DirAccess.make_dir_recursive_absolute("res://tests/captures")
			root.get_texture().get_image().save_png("res://tests/captures/level-%d.png" % number)
		player.take_damage(999)
		check(paused and current_scene.get_node("GameHUD").game_over, "death pauses level %d" % number)
		current_scene.get_node("GameHUD").restart_level()
		await process_frame
		await process_frame
		check(current_scene.scene_file_path == path and not paused, "restart keeps level %d" % number)
		check(get_first_node_in_group("player").health == 100, "restart restores health")
		current_scene.get_node("GameHUD").choose_level()
		await process_frame
		await process_frame
		check(current_scene.name == "LevelSelect" and not paused, "level selection works after level %d" % number)
	change_scene_to_file("res://Level.tscn")
	await process_frame
	await process_frame
	check(get_nodes_in_group("enemies").size() >= 3, "level one can spawn its first wave")
	var hud = current_scene.get_node("GameHUD")
	hud.show_pause()
	var enemy_count = get_nodes_in_group("enemies").size()
	await create_timer(0.85).timeout
	check(get_nodes_in_group("enemies").size() == enemy_count, "wave spawning stops during pause")
	hud.resume_game()
	await create_timer(0.85).timeout
	check(get_nodes_in_group("enemies").size() > enemy_count, "wave spawning resumes after pause")
	current_scene.get_node("GameHUD").choose_level()
	await process_frame
	await process_frame
	await create_timer(0.85).timeout
	check(current_scene.name == "LevelSelect" and get_nodes_in_group("enemies").is_empty(), "leaving a running wave cleans up enemies")
	current_scene.queue_free()
	await process_frame
	print("LEVEL CHECKS: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
