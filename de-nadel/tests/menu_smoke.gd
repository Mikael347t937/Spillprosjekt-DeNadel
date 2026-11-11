extends SceneTree

var failures = 0
var checks = 0
var capture = false
var settings: Node
var original_values: Array

func _initialize() -> void:
	capture = OS.get_cmdline_user_args().has("--capture")
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition: print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func take_capture(filename: String) -> void:
	if not capture: return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/captures")
	root.get_texture().get_image().save_png("res://tests/captures/" + filename)

func run() -> void:
	settings = root.get_node("GameSettings")
	original_values = [settings.volume, settings.fullscreen, settings.reduced_motion]
	settings.config_path = "user://menu-test-settings.cfg"
	root.size = Vector2i(1600, 900)
	var menu_scene = load("res://scenes/main_menu.tscn") as PackedScene
	if menu_scene == null:
		push_error("Main menu or a referenced level could not be loaded.")
		quit(1)
		return
	var menu = menu_scene.instantiate()
	root.add_child(menu)
	current_scene = menu
	await process_frame
	await create_timer(0.9).timeout
	check(menu.get_node("Interface/Menu").visible, "main menu is visible")
	check(menu.buttons.get_child_count() == 4, "four Norwegian menu actions")
	check(menu.buttons.get_child(0).text == "Start spill", "Norwegian start label")
	check(root.gui_get_focus_owner() == menu.buttons.get_child(0), "keyboard focus starts on Start spill")
	check(menu.buttons.get_child(0).get_node(menu.buttons.get_child(0).focus_neighbor_top) == menu.buttons.get_child(3), "keyboard navigation wraps")
	await take_capture("main-menu.png")
	for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(1280,800)]:
		root.size = dimensions
		await process_frame
		check(menu.buttons.get_global_rect().end.x <= menu.size.x and menu.buttons.get_global_rect().end.y < menu.size.y, "menu fits %dx%d" % [dimensions.x, dimensions.y])
	root.size = Vector2i(1600,900)
	await process_frame
	menu.buttons.get_child(1).pressed.emit()
	await process_frame
	check(menu.settings_panel.visible and not menu.menu.visible, "settings opens and hides main controls")
	menu.volume_slider.value = 41
	check(is_equal_approx(settings.volume, 0.41), "volume slider controls audio setting")
	check(menu.volume_value.text == "41 %", "volume percentage updates")
	menu.motion_toggle.button_pressed = true
	check(settings.reduced_motion and not menu.get_node("Atmosphere").is_processing(), "reduced motion stops animated effects")
	settings.volume = 0.99
	settings.load_settings()
	check(is_equal_approx(settings.volume, 0.41) and settings.reduced_motion, "settings persist to disk")
	await take_capture("settings.png")
	menu.get_node("Interface/Settings/Content/Back").pressed.emit()
	check(menu.menu.visible and menu.active_panel.is_empty(), "back returns to main menu")
	menu.buttons.get_child(2).pressed.emit()
	check(menu.about_panel.visible, "about opens")
	await take_capture("about.png")
	menu.close_panel()
	menu.request_quit()
	check(menu.get_node("QuitConfirmation").visible, "quit requires confirmation")
	menu.get_node("QuitConfirmation").hide()
	menu.buttons.get_child(0).pressed.emit()
	await process_frame
	await process_frame
	check(current_scene.scene_file_path == "res://scenes/level_select.tscn", "Start spill opens level selection")
	check(current_scene.get_node("Panel/Content/Level2").disabled, "level two is clearly unavailable")
	check(current_scene.get_node("Panel/Content/Level3").disabled, "level three is clearly unavailable")
	await take_capture("level-select.png")
	current_scene.open_level_one()
	await process_frame
	await process_frame
	check(current_scene.scene_file_path == "res://Level.tscn", "level one opens the existing gameplay scene")
	await create_timer(0.1).timeout
	await take_capture("level.png")
	change_scene_to_file("res://scenes/main_menu.tscn")
	await process_frame
	await process_frame
	check(current_scene.name == "MainMenu", "menu can load again after gameplay")
	settings.volume = original_values[0]
	settings.fullscreen = original_values[1]
	settings.reduced_motion = original_values[2]
	settings.apply_settings()
	settings.config_path = settings.DEFAULT_CONFIG_PATH
	DirAccess.remove_absolute("user://menu-test-settings.cfg")
	# Release audio playback before stopping the test process.
	current_scene.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	print("MENU CHECKS: %d passed, %d failed" % [checks-failures, failures])
	quit(1 if failures else 0)
