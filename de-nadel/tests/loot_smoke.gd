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

func bullet_count() -> int:
	var count = 0
	for child in current_scene.get_children():
		if child is RigidBody2D: count += 1
	return count

func drop_at_player(scene: String, player: Node2D) -> void:
	var pickup = load(scene).instantiate()
	pickup.position = player.position
	current_scene.add_child(pickup)
	await create_timer(0.1).timeout
	await settle()

func capture(name: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/captures")
	root.get_texture().get_image().save_png("res://tests/captures/" + name + ".png")

func run() -> void:
	root.size = Vector2i(1600, 900)
	root.get_node("RunInventory").reset()
	change_scene_to_file("res://Level-2.tscn")
	await settle()
	var player = get_first_node_in_group("player")
	var hud = current_scene.get_node("GameHUD")
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	player.set_physics_process(false)
	check(player.coins == 0 and player.shells == 0, "new run starts with an empty inventory")
	await drop_at_player("res://scenes/coin.tscn", player)
	check(player.coins == 1, "walking onto a coin collects it")
	var coin = load("res://scenes/coin.tscn").instantiate()
	coin.amount = 5
	coin.position = Vector2(900, 800)
	current_scene.add_child(coin)
	coin.collect(player)
	coin.collect(player)
	check(player.coins == 6, "duplicate callbacks cannot collect the same coin twice")
	check(hud.get_node("Screen/Inventory/Content/CoinsRow/Coins").text == "Mynter: 6", "coin HUD updates")
	await drop_at_player("res://scenes/ammo.tscn", player)
	check(player.shells == 8, "ammo crate adds eight shells")
	await drop_at_player("res://scenes/shotgun.tscn", player)
	check(player.has_shotgun and player.selected_weapon == 1 and player.shells == 14, "weapon pickup unlocks and equips shotgun")
	await capture("pickups-and-weapon")
	var gun = player.get_node("Node2D")
	var before = bullet_count()
	gun.shoot()
	check(bullet_count() == before + 3 and player.shells == 13, "shotgun fires three pellets for one shell")
	gun.shoot()
	check(bullet_count() == before + 3 and player.shells == 13, "cooldown prevents duplicate firing")
	gun.cooldown = 0
	player.shells = 1
	gun.shoot()
	check(player.shells == 0 and player.selected_weapon == 0, "empty shotgun automatically falls back to pistol")
	gun.cooldown = 0
	before = bullet_count()
	gun.shoot()
	check(bullet_count() == before + 1 and player.shells == 0, "pistol remains usable without ammo")
	hud.show_pause()
	gun.cooldown = 0
	before = bullet_count()
	gun.shoot()
	check(bullet_count() == before, "pause blocks shooting")
	hud.resume_game()
	for enemy in get_nodes_in_group("enemies"): enemy.take_damage(999)
	await settle()
	hud.open_next_level()
	await settle()
	player = get_first_node_in_group("player")
	hud = current_scene.get_node("GameHUD")
	check(player.coins == 6 and player.has_shotgun, "coins and weapon carry into the next level")
	player.collect_pickup(0, 5)
	hud.restart_level()
	await settle()
	player = get_first_node_in_group("player")
	hud = current_scene.get_node("GameHUD")
	check(player.coins == 6, "restart restores level-entry inventory instead of farming coins")
	player.set_physics_process(false)
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
		enemy.take_damage(999)
	await settle()
	var cage = current_scene.get_node("SupplyCage")
	check(cage.opening and hud.ending and not hud.level_won, "finale starts before victory menu")
	check(player.controls_locked and not paused, "player stops while the ending keeps animating")
	var health_before: int = player.health
	player.take_damage(999)
	check(player.health == health_before, "player cannot die during the ending")
	var cancel = InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	hud._unhandled_key_input(cancel)
	check(not paused, "Esc cannot freeze the short ending sequence")
	await create_timer(0.75).timeout
	check(cage.get_node("Spilled").get_child_count() == 24, "cage visibly releases a pile of syringes")
	check(cage.get_node("CollisionShape2D").disabled, "open cage no longer blocks the player")
	await capture("syringes-spilling")
	if not cage.opened: await cage.released
	await settle()
	check(hud.level_won and paused, "victory waits until the release animation finishes")
	check(hud.get_node("Screen/Dialog/Content/Title").text == "Diktaturet er beseiret!", "ending announces the defeat of the dictatorship")
	await capture("dictatorship-defeated")
	hud.open_next_level()
	await settle()
	player = get_first_node_in_group("player")
	check(player.coins == 0 and not player.has_shotgun, "replay starts a fresh run")
	current_scene.get_node("GameHUD").main_menu()
	await settle()
	current_scene.queue_free()
	await settle()
	print("LOOT CHECKS: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
