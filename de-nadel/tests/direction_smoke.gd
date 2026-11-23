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

func capture(filename: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"): return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/captures")
	root.get_texture().get_image().save_png("res://tests/captures/" + filename)

func run() -> void:
	root.size = Vector2i(1600, 900)
	var world = Node2D.new()
	root.add_child(world)
	current_scene = world
	var player = load("res://tanks.tscn").instantiate()
	world.add_child(player)
	player.position = Vector2(200, 300)
	var visual = player.get_node("Sprite2D")
	check(visual is AnimatedSprite2D, "player uses directional human sprite")
	check(not player.has_node("Node2D/SpecialBarrel6"), "tank barrel art is removed")
	for path in ["res://assets/characters/player.tres", "res://assets/characters/syringe_enemy.tres"]:
		var frames = load(path)
		for animation in frames.get_animation_names():
			var expected = 6 if path.ends_with("player.tres") and animation == "front" else 4
			check(frames.get_frame_count(animation) == expected, "walk cycle uses the supplied poses")
			for i in range(frames.get_frame_count(animation)):
				check(not frames.get_frame_texture(animation, i).get_image().is_invisible(), "animation never includes an empty frame")
	check(visual.sprite_frames.has_animation("side"), "protagonist has its own pixel profile")
	var boss = load("res://scenes/boss.tscn").instantiate()
	check(boss.custom_frames != visual.sprite_frames, "boss keeps separate placeholder artwork")
	boss.free()
	for entry in [["move_left", "side", false], ["move_right", "side", true], ["move_up", "back", false], ["move_down", "front", false]]:
		player.velocity = Vector2.ZERO
		Input.action_press(entry[0])
		await create_timer(0.2).timeout
		check(visual.animation == entry[1] and visual.flip_h == entry[2], "correct facing for " + entry[0])
		check(visual.is_playing(), "walking animates for " + entry[0])
		Input.action_release(entry[0])
		await create_timer(0.3).timeout
		check(not visual.is_playing() and visual.frame == 0, "stopping holds a visible neutral pose")
		check(visual.animation == entry[1] and visual.flip_h == entry[2], "idle remembers the last direction")
	visual.update_motion(Vector2(1, -1))
	check(visual.animation == "back" and not visual.flip_h, "upward diagonal has a stable back view")
	visual.update_motion(Vector2(-1, 1))
	check(visual.animation == "front" and not visual.flip_h, "downward diagonal has a stable front view")
	var wall = load("res://box.tscn").instantiate()
	wall.position = Vector2(250, 300)
	world.add_child(wall)
	player.position = Vector2(200, 300)
	player.velocity = Vector2.ZERO
	Input.action_press("move_right")
	await create_timer(0.6).timeout
	check(not visual.is_playing(), "pushing into a wall does not walk in place")
	Input.action_release("move_right")
	wall.queue_free()
	await process_frame
	var enemy = load("res://scenes/enemy.tscn").instantiate()
	enemy.position = Vector2(800, 300)
	world.add_child(enemy)
	for entry in [[Vector2(600, 300), "side", false], [Vector2(1000, 300), "side", true], [Vector2(800, 100), "back", false], [Vector2(800, 500), "front", false]]:
		player.position = entry[0]
		await create_timer(0.1).timeout
		var sprite = enemy.get_node("Sprite2D")
		check(sprite.animation == entry[1] and sprite.flip_h == entry[2], "syringe enemy faces the actual chase direction")
	enemy.queue_free()
	player.set_physics_process(false)
	for i in range(4):
		var actor = player if i == 0 else load("res://tanks.tscn").instantiate()
		if i != 0: world.add_child(actor)
		actor.set_physics_process(false)
		actor.position = Vector2(400 + 260 * i, 350)
		actor.get_node("Sprite2D").update_motion([Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT][i])
		var label = Label.new()
		label.text = ["Ned", "Opp", "Venstre", "Høyre"][i]
		label.position = Vector2(-35, 70)
		actor.add_child(label)
	await capture("player-directions.png")
	world.queue_free()
	await process_frame
	print("DIRECTION CHECKS: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
