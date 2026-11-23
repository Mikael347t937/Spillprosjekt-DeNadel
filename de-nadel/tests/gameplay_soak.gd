extends SceneTree

var checks = 0
var failures = 0
var shots = 0
var deaths = 0
var hit_events = 0
var physics_steps = 0
var capture_enabled = false

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
	await physics_frame
	await process_frame

func release_controls() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down"]: Input.action_release(action)

func steer_player(direction: Vector2) -> void:
	release_controls()
	if direction.x > 0.2: Input.action_press("move_right")
	if direction.x < -0.2: Input.action_press("move_left")
	if direction.y > 0.2: Input.action_press("move_down")
	if direction.y < -0.2: Input.action_press("move_up")

func capture(filename: String) -> void:
	if not capture_enabled: return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/captures")
	root.get_texture().get_image().save_png("res://tests/captures/" + filename + ".png")

func observe_player() -> void:
	get_first_node_in_group("player").health_changed.connect(func(_current: int, _maximum: int) -> void: hit_events += 1)

func run() -> void:
	root.size = Vector2i(1600, 900)
	capture_enabled = OS.get_cmdline_user_args().has("--capture")
	for number in [1, 2, 3]:
		var path = "res://Level.tscn" if number == 1 else "res://Level-%d.tscn" % number
		change_scene_to_file(path)
		await settle()
		var player = get_first_node_in_group("player")
		observe_player()
		check(current_scene.y_sort_enabled, "level %d sorts characters and crates by depth" % number)
		check(not current_scene.has_node("Bounds/NorthFence"), "level %d has no dark strip across character heads" % number)
		# Test the upper edge with real movement against the collision boundary.
		for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
		player.position = Vector2(200, 240)
		Input.action_press("move_up")
		await create_timer(0.65).timeout
		release_controls()
		player.velocity = Vector2.ZERO
		check(player.position.y >= 222, "player's head stays below the building row on level %d" % number)
		await capture("top-boundary-level-%d" % number)
		if number == 2:
			player.set_physics_process(false)
			for box in current_scene.get_children():
				if not box is StaticBody2D or not box.has_node("Sprite2D"): continue
				for side in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
					player.position = box.position + side * 70
					await physics_frame
					check(player.test_move(player.global_transform, -side * 50), "crate %s blocks entry from %s" % [box.name, side])
			player.position = current_scene.get_node("Box8").position + Vector2(0, 58)
			await capture("player-in-front-of-crate")
			player.set_physics_process(true)
		# Restart restores normal AI after the boundary fixture.
		current_scene.get_node("GameHUD").restart_level()
		await settle()
		observe_player()
		var deadline = Time.get_ticks_msec() + 20000
		var started = Time.get_ticks_msec()
		var paused_once = false
		while Time.get_ticks_msec() < deadline:
			await physics_frame
			physics_steps += 1
			player = get_first_node_in_group("player")
			var hud = current_scene.get_node("GameHUD")
			if player.dead:
				deaths += 1
				check(paused and hud.game_over, "real combat death opens game-over controls")
				release_controls()
				hud.restart_level()
				await settle()
				observe_player()
				continue
			if hud.ending or hud.level_won: break
			if not paused_once and Time.get_ticks_msec() - started > 5000:
				paused_once = true
				release_controls()
				hud.show_pause()
				var before: Vector2 = player.position
				await create_timer(0.3).timeout
				check(player.position == before, "pause freezes movement during sustained combat")
				hud.show_settings()
				hud.close_settings()
				hud.resume_game()
			var nearest: Node2D = null
			var distance = INF
			for enemy in get_nodes_in_group("enemies"):
				var current_distance = player.position.distance_squared_to(enemy.position)
				if not enemy.dead and current_distance < distance:
					distance = current_distance
					nearest = enemy
			var elapsed = (Time.get_ticks_msec() - started) / 1000.0
			var direction = Vector2(cos(elapsed * 0.65), sin(elapsed * 0.65))
			if nearest:
				var away = nearest.position.direction_to(player.position)
				direction = (away * 0.7 + away.orthogonal() * 0.9).normalized()
				var gun = player.get_node("Node2D")
				gun.look_at(nearest.global_position)
				if gun.cooldown <= 0:
					gun.shoot()
					shots += 1
			if player.position.x < 120: direction.x = 1
			if player.position.x > 1460: direction.x = -1
			if player.position.y < 290: direction.y = 1
			if player.position.y > 800: direction.y = -1
			steer_player(direction)
			check_bounds(player, number)
			if physics_steps % 120 == 0: await capture("combat-soak-level-%d" % number)
		release_controls()
		print("SOAK: level %d ran for %.1f seconds" % [number, (Time.get_ticks_msec() - started) / 1000.0])
		check(not get_nodes_in_group("enemies").is_empty() or current_scene.completed or not current_scene.objective_ready() or current_scene.waves != null, "level %d keeps a valid combat/completion state" % number)
	check(shots > 30 and physics_steps > 1000, "sustained test exercised real projectiles and movement over time")
	current_scene.queue_free()
	paused = false
	await settle()
	await create_timer(0.3).timeout
	print("SOAK: %d physics steps, %d shots, %d hit events, %d deaths/restarts" % [physics_steps, shots, hit_events, deaths])
	print("SOAK CHECKS: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)

func check_bounds(player: Node2D, number: int) -> void:
	if not player.position.is_finite() or player.position.x < 25 or player.position.x > 1575 or player.position.y < 220 or player.position.y > 870:
		check(false, "player remains inside level %d: %s" % [number, player.position])
