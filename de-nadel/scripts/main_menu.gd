extends Control

@export var first_scene: PackedScene = preload("res://scenes/level_select.tscn")
@onready var menu: Control = $Interface/Menu
@onready var settings_panel: Control = $Interface/Settings
@onready var about_panel: Control = $Interface/About
@onready var scrim: ColorRect = $Interface/Scrim
@onready var fade: ColorRect = $Fade
@onready var buttons: VBoxContainer = $Interface/Menu/Buttons
@onready var volume_slider: HSlider = $Interface/Settings/Content/Volume
@onready var volume_value: Label = $Interface/Settings/Content/VolumeTitle/Value
@onready var fullscreen_toggle: CheckButton = $Interface/Settings/Content/Fullscreen
@onready var motion_toggle: CheckButton = $Interface/Settings/Content/ReducedMotion
var active_panel = ""
var transitioning = false
var last_button: Button

func _ready() -> void:
	$Interface/Menu/Buttons/Start.pressed.connect(start_game)
	$Interface/Menu/Buttons/Settings.pressed.connect(func() -> void: open_panel("settings"))
	$Interface/Menu/Buttons/About.pressed.connect(func() -> void: open_panel("about"))
	$Interface/Menu/Buttons/Quit.pressed.connect(request_quit)
	$Interface/Settings/Content/Back.pressed.connect(close_panel)
	$Interface/About/Content/Back.pressed.connect(close_panel)
	$QuitConfirmation.confirmed.connect(func() -> void: get_tree().quit())
	$QuitConfirmation.canceled.connect(func() -> void: $Interface/Menu/Buttons/Quit.grab_focus())
	for i in range(buttons.get_child_count()):
		var button: Button = buttons.get_child(i)
		button.focus_neighbor_top = button.get_path_to(buttons.get_child((i + 3) % 4))
		button.focus_neighbor_bottom = button.get_path_to(buttons.get_child((i + 1) % 4))
		button.mouse_entered.connect(func() -> void:
			if not transitioning and active_panel.is_empty(): button.grab_focus())
		button.pressed.connect(play_click)
	volume_slider.value = GameSettings.volume * 100
	volume_value.text = "%d %%" % roundi(volume_slider.value)
	fullscreen_toggle.button_pressed = GameSettings.fullscreen
	motion_toggle.button_pressed = GameSettings.reduced_motion
	volume_slider.value_changed.connect(_volume_changed)
	fullscreen_toggle.toggled.connect(_fullscreen_changed)
	motion_toggle.toggled.connect(_motion_changed)
	if DisplayServer.get_name() != "headless":
		var drone: AudioStreamWAV = $Ambience.stream
		drone.loop_mode = AudioStreamWAV.LOOP_FORWARD
		drone.loop_begin = 0
		drone.loop_end = int(drone.get_length() * drone.mix_rate)
		$Ambience.play()
	fade.color.a = 1.0
	if GameSettings.reduced_motion:
		fade.color.a = 0.0
	else:
		create_tween().tween_property(fade, "color:a", 0.0, 0.8)
	buttons.get_child(0).grab_focus()

func play_click() -> void:
	if is_inside_tree() and DisplayServer.get_name() != "headless": $Click.play()

func open_panel(panel_name: String) -> void:
	if transitioning: return
	last_button = get_viewport().gui_get_focus_owner() as Button
	active_panel = panel_name
	menu.hide()
	scrim.show()
	settings_panel.visible = panel_name == "settings"
	about_panel.visible = panel_name == "about"
	if panel_name == "settings": volume_slider.grab_focus()
	else: $Interface/About/Content/Back.grab_focus()

func close_panel() -> void:
	GameSettings.save_settings()
	active_panel = ""
	settings_panel.hide()
	about_panel.hide()
	scrim.hide()
	menu.show()
	if is_instance_valid(last_button): last_button.grab_focus()
	else: buttons.get_child(0).grab_focus()

func _volume_changed(value: float) -> void:
	GameSettings.volume = value / 100.0
	volume_value.text = "%d %%" % roundi(value)
	GameSettings.apply_settings()
	GameSettings.save_settings()

func _fullscreen_changed(value: bool) -> void:
	GameSettings.fullscreen = value
	GameSettings.apply_settings()
	GameSettings.save_settings()

func _motion_changed(value: bool) -> void:
	GameSettings.reduced_motion = value
	GameSettings.apply_settings()
	GameSettings.save_settings()

func start_game() -> void:
	if transitioning: return
	transitioning = true
	for button in buttons.get_children(): button.disabled = true
	if not GameSettings.reduced_motion:
		await create_tween().tween_property(fade, "color:a", 1.0, 0.45).finished
	var error = get_tree().change_scene_to_packed(first_scene)
	if error != OK:
		transitioning = false
		for button in buttons.get_children(): button.disabled = false
		fade.color.a = 0
		push_error("Kunne ikke åpne startscenen.")

func request_quit() -> void:
	if not transitioning: $QuitConfirmation.popup_centered(Vector2i(420, 160))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not active_panel.is_empty():
			close_panel()
			get_viewport().set_input_as_handled()
		elif not transitioning:
			request_quit()
			get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	$Ambience.stop()
	$Click.stop()
