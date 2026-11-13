extends SceneTree

var checks = 0
var failures = 0

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

func stop_enemies() -> void:
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)

func defeat_all() -> void:
	stop_enemies()
	for enemy in get_nodes_in_group("enemies"):
		enemy.take_damage(999)
	await settle()

func capture(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/captures")
	root.get_texture().get_image().save_png("res://tests/captures/" + name + ".png")

func run() -> void:
	root.size = Vector2i(1600, 900)
	var level = load("res://Level.tscn").instantiate()
	level.get_node("WaveManager").spawn_delay = 0.04
	level.get_node("WaveManager").first_wave_enemies = 3
	root.add_child(level)
	current_scene = level
	await settle()
	var hud = level.get_node("GameHUD")
	var manager = level.get_node("WaveManager")
	check(manager.max_waves == 1, "level one has one wave")
	var original_enemy = level.get_node("Enemy")
	stop_enemies()
	for enemy in get_nodes_in_group("enemies"):
		if enemy != original_enemy: enemy.take_damage(999)
	await settle()
	check(not paused and not hud.level_won, "cannot finish while wave is still spawning")
	await create_timer(0.2).timeout
	stop_enemies()
	for enemy in get_nodes_in_group("enemies"):
		if enemy != original_enemy: enemy.take_damage(999)
	await settle()
	check(manager.finished and not paused, "original enemies must also be defeated")
	original_enemy.take_damage(999)
	await settle()
	check(hud.level_won and paused and hud.dialog.visible, "last enemy completes level one")
	var visible_buttons = 0
	for child in hud.get_node("Screen/Dialog/Content").get_children():
		if child is Button and child.visible: visible_buttons += 1
	check(visible_buttons == 2, "victory offers exactly two buttons")
	var cancel = InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	hud._unhandled_key_input(cancel)
	hud.resume_game()
	check(paused and hud.dialog.visible, "Esc and resume cannot reopen a completed level")
	await capture("level-complete")
	hud.get_node("Screen/Dialog/Content/Next").pressed.emit()
	hud.open_next_level()
	await settle()
	check(current_scene.scene_file_path == "res://Level-2.tscn" and not paused, "next opens level two once and unpauses")
	check(get_first_node_in_group("player").health == 100, "next level starts with full health")
	await defeat_all()
	hud = current_scene.get_node("GameHUD")
	check(hud.level_won and paused, "level two ends after its enemies are defeated")
	hud.get_node("Screen/Dialog/Content/Next").pressed.emit()
	await settle()
	check(current_scene.scene_file_path == "res://Level-3.tscn" and not paused, "next opens level three")
	await defeat_all()
	hud = current_scene.get_node("GameHUD")
	check(hud.level_won and paused, "level three also completes")
	check(hud.get_node("Screen/Dialog/Content/Next").text == "Spill igjen", "last level offers replay instead of a missing fourth level")
	await capture("game-complete")
	hud.get_node("Screen/Dialog/Content/Next").pressed.emit()
	await settle()
	check(current_scene.scene_file_path == "res://Level.tscn" and not paused, "replay starts level one")
	change_scene_to_file("res://Level-2.tscn")
	await settle()
	await defeat_all()
	current_scene.get_node("GameHUD/Screen/Dialog/Content/Menu").pressed.emit()
	await settle()
	check(current_scene.name == "MainMenu" and not paused, "victory menu returns to main menu")
	change_scene_to_file("res://Level-2.tscn")
	await settle()
	stop_enemies()
	get_first_node_in_group("player").take_damage(999)
	await defeat_all()
	hud = current_scene.get_node("GameHUD")
	check(hud.game_over and not hud.level_won, "death takes priority over victory")
	check(not hud.get_node("Screen/Dialog/Content/Next").visible, "death does not show a next-level button")
	paused = false
	current_scene.queue_free()
	await settle()
	print("COMPLETION CHECKS: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
