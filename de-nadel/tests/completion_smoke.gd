extends SceneTree

var checks = 0
var failures = 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if ok: print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func settle() -> void:
	await process_frame
	await process_frame
	await process_frame

func freeze_guards() -> void:
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)

func defeat_all() -> void:
	freeze_guards()
	for enemy in get_nodes_in_group("enemies"): enemy.take_damage(999)
	await settle()

func capture(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/captures")
	root.get_texture().get_image().save_png("res://tests/captures/" + name + ".png")

func run() -> void:
	root.size = Vector2i(1600, 900)
	root.get_node("RunInventory").reset()
	var level = load("res://Level.tscn").instantiate()
	level.get_node("WaveManager").spawn_delay = 0.04
	level.get_node("WaveManager").first_wave_enemies = 3
	root.add_child(level)
	current_scene = level
	await settle()
	var player = get_first_node_in_group("player")
	player.set_physics_process(false)
	var portal = level.get_node("Portal")
	var hud = level.get_node("GameHUD")
	check(not level.has_node("SecondArena") and not level.has_node("ThirdArena"), "only the original map is present")
	check(not portal.unlocked, "portal starts locked during combat")
	check(not hud.get_node("Screen/Hint").visible and hud.get_node("Screen/Health").size.y < 65, "compact HUD and hidden keyboard instructions are preserved")
	for enemy in get_nodes_in_group("enemies"):
		check(not enemy.get_node("HealthBar").visible, "regular enemies have no overhead health bar")
	freeze_guards()
	player.position = portal.position
	await create_timer(0.08).timeout
	check(current_scene == level and not level.completed, "touching a locked portal cannot skip the fight")
	player.position = Vector2(575, 400)
	await defeat_all()
	check(not portal.unlocked, "portal waits while the wave is spawning")
	await create_timer(0.2).timeout
	await defeat_all()
	check(level.waves.finished and not portal.unlocked, "clearing guards does not skip the shotgun objective")
	level.get_node("Shotgun").collect(player)
	await settle()
	check(level.completed and portal.unlocked and not paused and not hud.level_won, "full objective unlocks the portal without pausing gameplay")
	check(not portal.get_node("Shutter").visible, "open portal changes visibly")
	await capture("level-portal-open")
	hud.show_pause()
	player.position = portal.position
	await create_timer(0.15).timeout
	check(current_scene == level, "pause prevents portal travel")
	hud.resume_game()
	await create_timer(0.15).timeout
	await settle()
	check(current_scene.scene_file_path == "res://Level-2.tscn" and not paused, "walking into the first portal opens level two")
	player = get_first_node_in_group("player")
	player.set_physics_process(false)
	check(player.health == 100 and player.has_shotgun, "next level restores health and preserves the weapon")
	level = current_scene
	portal = level.get_node("Portal")
	check(not level.has_node("SecondArena") and not level.has_node("ThirdArena"), "level two also has just one original map")
	await defeat_all()
	check(not portal.unlocked, "warehouse portal waits for the list")
	player.position = level.get_node("Lagerliste").position
	await create_timer(0.12).timeout
	check(portal.unlocked and not paused, "real list pickup opens the second portal")
	player.position = portal.position
	await create_timer(0.15).timeout
	await settle()
	check(current_scene.scene_file_path == "res://Level-3.tscn", "second portal opens the original third level")
	check(not current_scene.has_node("Portal") and not current_scene.has_node("ThirdArena"), "last level has the boss ending rather than extra rooms")
	hud = current_scene.get_node("GameHUD")
	check(hud.get_node("Screen/BossHealth").visible, "boss health is visible in the third level")
	await defeat_all()
	var cage = current_scene.get_node("SupplyCage")
	if not cage.opened: await cage.released
	await settle()
	check(hud.level_won and paused, "boss and guards still lead to the cage finale")
	check(hud.get_node("Screen/Dialog/Content/Next").text == "Spill igjen", "final victory offers replay")
	hud.open_next_level()
	await settle()
	check(current_scene.scene_file_path == "res://Level.tscn" and not paused, "replay returns to the first of three levels")
	current_scene.get_node("GameHUD").choose_level()
	await settle()
	check(current_scene.name == "LevelSelect", "level selection still works")
	change_scene_to_file("res://Level-2.tscn")
	await settle()
	freeze_guards()
	player = get_first_node_in_group("player")
	player.take_damage(999)
	check(paused and current_scene.get_node("GameHUD").game_over, "death still opens game over")
	current_scene.get_node("GameHUD").restart_level()
	await settle()
	check(not current_scene.get_node("Portal").unlocked and not paused, "restart closes the portal and resets combat")
	current_scene.queue_free()
	await settle()
	# Give the native audio thread time to release the last short effect.
	await create_timer(0.3).timeout
	print("COMPLETION CHECKS: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
