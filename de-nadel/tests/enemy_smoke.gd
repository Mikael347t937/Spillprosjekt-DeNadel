extends SceneTree

var failures = 0
var checks = 0
var world: Node2D
var bullet_scene = preload("res://bullet.tscn")

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition: print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func shoot() -> Node2D:
	var bullet = bullet_scene.instantiate()
	world.add_child(bullet)
	bullet.global_position = Vector2.ZERO
	return bullet

func run() -> void:
	world = Node2D.new()
	root.add_child(world)
	current_scene = world
	var player = Marker2D.new()
	player.add_to_group("player")
	world.add_child(player)
	var enemy = load("res://scenes/enemy.tscn").instantiate()
	enemy.position = Vector2(220, 0)
	world.add_child(enemy)
	await physics_frame
	check(enemy.target == player, "enemy finds player")
	check(enemy.get_node("Body") is Polygon2D and enemy.get_node("Body").color == Color.BLACK, "black square without an icon")
	var start_x: float = enemy.position.x
	await create_timer(0.15).timeout
	check(enemy.position.x < start_x, "enemy moves toward player without keyboard input")
	enemy.set_physics_process(false)
	enemy.position = Vector2(220, 0)
	enemy.take_damage(-1)
	check(enemy.health == 3, "invalid damage does not change health")
	for hit_number in range(1, 4):
		var bullet = shoot()
		await create_timer(0.42).timeout
		check(not is_instance_valid(bullet), "bullet consumed on hit %d" % hit_number)
		if hit_number < 3:
			check(enemy.health == 3 - hit_number, "one health point lost per shot")
	check(not is_instance_valid(enemy), "enemy disappears after three physical bullet hits")
	var expired_bullet = bullet_scene.instantiate()
	expired_bullet.lifetime = 0.03
	world.add_child(expired_bullet)
	await create_timer(0.12).timeout
	check(not is_instance_valid(expired_bullet), "missed bullet expires")
	var wall = load("res://box.tscn").instantiate()
	wall.position = Vector2(100, 0)
	world.add_child(wall)
	var blocked = shoot()
	await create_timer(0.3).timeout
	check(not is_instance_valid(blocked), "bullet consumed by obstacle")
	world.queue_free()
	await process_frame
	print("ENEMY CHECKS: %d passed, %d failed" % [checks-failures, failures])
	quit(1 if failures else 0)
