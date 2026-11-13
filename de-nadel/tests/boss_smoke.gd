extends SceneTree

var checks = 0
var failures = 0
var shots_fired = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, description: String) -> void:
	checks += 1
	if ok: print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func settle() -> void:
	await process_frame
	await process_frame
	await process_frame

func clear_shots() -> void:
	for shot in get_nodes_in_group("enemy_projectiles"): shot.queue_free()

func capture(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/captures")
	root.get_texture().get_image().save_png("res://tests/captures/" + name + ".png")

func run() -> void:
	root.size = Vector2i(1600, 900)
	change_scene_to_file("res://Level-3.tscn")
	await settle()
	var boss = get_first_node_in_group("bosses")
	var player = get_first_node_in_group("player")
	var hud = current_scene.get_node("GameHUD")
	check(boss != null and boss.is_in_group("enemies"), "level three contains a boss counted as an enemy")
	check(boss.health == 18 and hud.get_node("Screen/BossHealth").visible, "boss starts with visible health")
	check(hud.get_node("Screen/BossHealth/Content/Bar").value == 18, "HUD shows boss health")
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
		if enemy != boss:
			check(enemy.get_node("Sprite2D") is AnimatedSprite2D, "basic enemy uses animated Piskel art")
			check(enemy.get_node("Sprite2D").sprite_frames.get_frame_count("walk") == 4, "enemy has four animation frames")
	player.set_physics_process(false)
	await capture("boss-arena")
	node_added.connect(func(node: Node) -> void:
		if node.is_in_group("enemy_projectiles"): shots_fired += 1)
	player.position = Vector2(260, 280)
	boss.position = Vector2(680, 280)
	boss.shot_warning = 0.18
	boss.prepare_attack()
	boss.set_physics_process(true)
	await create_timer(0.08).timeout
	check(shots_fired == 0 and boss.get_node("Warning").visible, "boss warns before shooting")
	hud.show_pause()
	var timer_before: float = boss.state_time
	await create_timer(0.15).timeout
	check(boss.state_time == timer_before and shots_fired == 0, "pause freezes boss attacks")
	hud.resume_game()
	await create_timer(1.8).timeout
	boss.set_physics_process(false)
	check(shots_fired == 3, "boss fires a three-shot burst")
	check(player.health < 100 and not player.dead, "boss projectiles physically hit the player")
	clear_shots()
	await settle()
	var wall = load("res://box.tscn").instantiate()
	wall.position = Vector2(470, 280)
	current_scene.add_child(wall)
	await physics_frame
	boss.next_is_dash = false
	boss.prepare_attack()
	var health_before: int = player.health
	boss.set_physics_process(true)
	await create_timer(1.8).timeout
	boss.set_physics_process(false)
	check(player.health == health_before, "cover blocks the boss burst")
	clear_shots()
	wall.queue_free()
	await settle()
	player.position = Vector2(480, 280)
	player.hit_cooldown = 0
	boss.position = Vector2(680, 280)
	boss.dash_warning = 0.18
	boss.next_is_dash = true
	boss.prepare_attack()
	await capture("boss-warning")
	boss.set_physics_process(true)
	await create_timer(0.08).timeout
	check(boss.position == Vector2(680, 280), "dash has a stationary warning period")
	await create_timer(0.5).timeout
	boss.set_physics_process(false)
	check(player.health == health_before - 25, "dash damages the player once")
	check(boss.state == "rest", "boss rests after dashing")
	wall = load("res://box.tscn").instantiate()
	wall.position = Vector2(600, 280)
	current_scene.add_child(wall)
	player.position = Vector2(400, 280)
	boss.position = Vector2(750, 280)
	player.hit_cooldown = 0
	boss.attack_timer = 0
	await physics_frame
	boss.next_is_dash = true
	boss.prepare_attack()
	health_before = player.health
	boss.set_physics_process(true)
	await create_timer(0.6).timeout
	boss.set_physics_process(false)
	check(boss.position.x > 640 and boss.state == "rest", "dash stops against a crate")
	check(player.health == health_before, "dash cannot damage through cover")
	wall.queue_free()
	await settle()
	boss.position = Vector2(750, 280)
	boss.take_damage(-5)
	check(boss.health == 18, "boss ignores invalid damage")
	var bullet = load("res://bullet.tscn").instantiate()
	bullet.position = Vector2(620, 280)
	current_scene.add_child(bullet)
	await create_timer(0.3).timeout
	check(boss.health == 17, "player bullet physically damages boss")
	boss.take_damage(8)
	check(boss.second_phase and boss.health == 9, "half health activates the second phase")
	check(hud.get_node("Screen/BossHealth/Content/Bar").value == 9, "damage updates boss HUD")
	for enemy in get_nodes_in_group("enemies"):
		if enemy != boss: enemy.take_damage(999)
	await settle()
	check(not hud.level_won, "defeating guards does not finish the boss level")
	boss.take_damage(999)
	await settle()
	check(hud.level_won and paused, "boss death completes level three")
	hud.restart_level()
	await settle()
	boss = get_first_node_in_group("bosses")
	check(boss.health == 18 and not boss.second_phase and not paused, "restart resets boss and phase")
	current_scene.get_node("GameHUD").choose_level()
	await settle()
	check(get_nodes_in_group("bosses").is_empty() and get_nodes_in_group("enemy_projectiles").is_empty(), "leaving the arena cleans up boss and projectiles")
	current_scene.queue_free()
	await settle()
	print("BOSS CHECKS: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
