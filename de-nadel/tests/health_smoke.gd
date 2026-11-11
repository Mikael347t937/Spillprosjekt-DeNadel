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

func capture(filename: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/captures")
	root.get_texture().get_image().save_png("res://tests/captures/" + filename)

func run() -> void:
	root.size = Vector2i(1600, 900)
	var level = load("res://Level.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	await process_frame
	var player = get_first_node_in_group("player")
	var hud = level.get_node("GameHUD")
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	player.set_physics_process(false)
	check(player.health == 100 and not player.dead, "player starts alive with full health")
	check(hud.health_bar.value == 100, "HUD shows initial health")
	player.take_damage(20)
	check(player.health == 80 and hud.health_bar.value == 80, "damage updates player and HUD")
	await capture("health.png")
	player.take_damage(20)
	check(player.health == 80, "short grace period prevents stacked hits")
	player.hit_cooldown = 0
	player.take_damage(-5)
	check(player.health == 80, "negative damage is ignored")
	var enemy = get_nodes_in_group("enemies")[0]
	player.position = Vector2(100, 100)
	enemy.position = Vector2(155, 100)
	enemy.target = player
	enemy.attack_timer = 0
	await physics_frame
	await process_frame
	enemy.try_attack()
	check(player.health == 60, "nearby enemy can damage player")
	enemy.try_attack()
	check(player.health == 60, "enemy cannot attack continuously")
	var wall = load("res://box.tscn").instantiate()
	wall.position = Vector2(125, 100)
	level.add_child(wall)
	await physics_frame
	await process_frame
	player.hit_cooldown = 0
	enemy.attack_timer = 0
	enemy.try_attack()
	check(player.health == 60, "wall blocks melee damage")
	hud.show_pause()
	check(paused and hud.dialog.visible, "pause freezes the level")
	await capture("pause.png")
	var position_before: Vector2 = enemy.position
	await create_timer(0.1).timeout
	check(enemy.position == position_before, "enemy stays still while paused")
	hud.show_settings()
	check(hud.options.visible and paused, "settings are usable during pause")
	hud.close_settings()
	hud.resume_game()
	check(not paused and not hud.dialog.visible, "resume unpauses the level")
	player.hit_cooldown = 0
	player.take_damage(999)
	check(player.health == 0 and player.dead, "lethal damage clamps health to zero")
	check(paused and hud.game_over and hud.dialog.visible, "death opens game-over controls")
	await capture("game-over.png")
	player.take_damage(10)
	check(player.health == 0, "dead player ignores further hits")
	hud.restart_level()
	await process_frame
	await process_frame
	player = get_first_node_in_group("player")
	check(not paused and player.health == 100 and not player.dead, "restart resets health and pause state")
	for other in get_nodes_in_group("enemies"): other.set_physics_process(false)
	for action in ["move_left", "move_right", "move_up", "move_down", "shoot"]:
		check(InputMap.has_action(action), "gameplay action exists: " + action)
	check(not InputMap.event_is_action(InputMap.action_get_events("ui_accept")[0], "shoot"), "confirm action is not used as shooting action")
	current_scene.get_node("GameHUD").choose_level()
	await process_frame
	await process_frame
	check(current_scene.name == "LevelSelect" and not paused, "level selector works after leaving gameplay")
	current_scene.queue_free()
	await process_frame
	print("HEALTH CHECKS: %d passed, %d failed" % [checks-failures, failures])
	quit(1 if failures else 0)
