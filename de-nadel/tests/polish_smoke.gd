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

func run() -> void:
	var world = Node2D.new()
	root.add_child(world)
	current_scene = world
	var player = load("res://tanks.tscn").instantiate()
	player.position = Vector2(440, 300)
	world.add_child(player)
	player.set_physics_process(false)
	var box = load("res://box.tscn").instantiate()
	box.position = Vector2(280, 300)
	world.add_child(box)
	var paths = load("res://scripts/path_grid.gd").new()
	world.add_child(paths)
	await physics_frame
	await process_frame
	check(paths.ready_for_paths, "navigation scans real collision shapes")
	var route = paths.route(Vector2(160, 300), player.position)
	var detours = false
	for point in route:
		if absf(point.y - 300) > 35: detours = true
	check(detours, "route goes around the crate rather than through it")
	var enemy = load("res://scenes/enemy.tscn").instantiate()
	enemy.position = Vector2(160, 300)
	enemy.speed = 160
	world.add_child(enemy)
	await create_timer(2.5).timeout
	check(enemy.position.x > 320, "enemy physically walks past the blocking crate (%s)" % enemy.position)
	box.queue_free()
	player.position = Vector2(440, 300)
	enemy.position = Vector2(390, 300)
	enemy.winding_up = false
	enemy.attack_timer = 0
	player.hit_cooldown = 0
	var health_before: int = player.health
	await create_timer(0.1).timeout
	check(enemy.winding_up and enemy.get_node("AttackTell").visible and player.health == health_before, "melee attack warns before doing damage")
	var windup_before: float = enemy.windup_left
	paused = true
	await create_timer(0.1).timeout
	check(is_equal_approx(enemy.windup_left, windup_before), "pause also freezes the melee warning")
	paused = false
	player.position = Vector2(650, 300)
	await create_timer(0.3).timeout
	check(player.health == health_before, "moving away during the warning dodges the attack")
	world.queue_free()
	await process_frame
	change_scene_to_file("res://Level-2.tscn")
	await process_frame
	await process_frame
	player = get_first_node_in_group("player")
	player.set_physics_process(false)
	for guard in get_nodes_in_group("enemies"): guard.take_damage(999)
	await process_frame
	await process_frame
	check(not current_scene.get_node("GameHUD").level_won, "guards alone do not complete the warehouse objective")
	player.position = current_scene.get_node("Lagerliste").position
	await create_timer(0.12).timeout
	check(current_scene.supplies_collected and current_scene.get_node("Portal").unlocked, "walking onto the warehouse list opens the exit portal")
	check(not paused, "player remains free to enter the portal")
	paused = false
	current_scene.queue_free()
	await process_frame
	var audio = root.get_node("GameAudio")
	for clip in [audio.PISTOL, audio.SHOTGUN, audio.IMPACT, audio.PICKUP]:
		check(clip is AudioStreamWAV and clip.get_length() > 0, "sound effect has real audio data")
	print("POLISH CHECKS: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
