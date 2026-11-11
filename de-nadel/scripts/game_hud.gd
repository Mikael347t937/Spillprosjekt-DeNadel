extends CanvasLayer

@onready var health_bar: ProgressBar = $Screen/Health/Content/Bar
@onready var health_label: Label = $Screen/Health/Content/Label
@onready var dialog: PanelContainer = $Screen/Dialog
@onready var shade: ColorRect = $Screen/Shade
@onready var options: VBoxContainer = $Screen/Dialog/Content/Options
var game_over = false
var changing_scene = false

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(update_health)
		player.died.connect(show_game_over)
		update_health(player.health, player.max_health)
	$Screen/Dialog/Content/Resume.pressed.connect(resume_game)
	$Screen/Dialog/Content/Settings.pressed.connect(show_settings)
	$Screen/Dialog/Content/Restart.pressed.connect(restart_level)
	$Screen/Dialog/Content/Levels.pressed.connect(choose_level)
	$Screen/Dialog/Content/Menu.pressed.connect(main_menu)
	$Screen/Dialog/Content/Quit.pressed.connect(func() -> void: $ConfirmQuit.popup_centered())
	$ConfirmQuit.confirmed.connect(func() -> void: get_tree().quit())
	$Screen/Dialog/Content/Options/Back.pressed.connect(close_settings)
	$Screen/Dialog/Content/Options/Volume.value = GameSettings.volume * 100
	$Screen/Dialog/Content/Options/Fullscreen.button_pressed = GameSettings.fullscreen
	$Screen/Dialog/Content/Options/Volume.value_changed.connect(change_volume)
	$Screen/Dialog/Content/Options/Fullscreen.toggled.connect(change_fullscreen)

func update_health(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "Liv: %d / %d" % [current, maximum]

func show_pause() -> void:
	get_tree().paused = true
	shade.show()
	dialog.show()
	$Screen/Dialog/Content/Title.text = "Pause"
	$Screen/Dialog/Content/Resume.grab_focus()

func resume_game() -> void:
	if game_over: return
	dialog.hide()
	shade.hide()
	get_tree().paused = false

func show_game_over() -> void:
	game_over = true
	show_pause()
	$Screen/Dialog/Content/Title.text = "Du døde"
	$Screen/Dialog/Content/Resume.hide()
	$Screen/Dialog/Content/Restart.grab_focus()

func show_settings() -> void:
	for name in ["Resume", "Settings", "Restart", "Levels", "Menu", "Quit"]:
		get_node("Screen/Dialog/Content/" + name).hide()
	options.show()
	$Screen/Dialog/Content/Title.text = "Innstillinger"
	$Screen/Dialog/Content/Options/Volume.grab_focus()

func close_settings() -> void:
	options.hide()
	for name in ["Settings", "Restart", "Levels", "Menu", "Quit"]:
		get_node("Screen/Dialog/Content/" + name).show()
	$Screen/Dialog/Content/Resume.visible = not game_over
	$Screen/Dialog/Content/Title.text = "Du døde" if game_over else "Pause"
	$Screen/Dialog/Content/Settings.grab_focus()

func change_volume(value: float) -> void:
	GameSettings.volume = value / 100.0
	GameSettings.apply_settings()
	GameSettings.save_settings()

func change_fullscreen(value: bool) -> void:
	GameSettings.fullscreen = value
	GameSettings.apply_settings()
	GameSettings.save_settings()

func restart_level() -> void:
	if changing_scene: return
	changing_scene = true
	get_tree().paused = false
	get_tree().reload_current_scene()

func choose_level() -> void:
	leave_for("res://scenes/level_select.tscn")

func main_menu() -> void:
	leave_for("res://scenes/main_menu.tscn")

func leave_for(scene: String) -> void:
	if changing_scene: return
	changing_scene = true
	get_tree().paused = false
	get_tree().change_scene_to_file(scene)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if options.visible: close_settings()
		elif game_over: return
		elif dialog.visible: resume_game()
		else: show_pause()
		get_viewport().set_input_as_handled()
