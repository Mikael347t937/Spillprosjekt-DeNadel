extends Control

@export var level_one: PackedScene = preload("res://Level.tscn")
var opening = false

func _ready() -> void:
	get_tree().paused = false
	$Panel/Content/Level1.pressed.connect(open_level_one)
	$Panel/Content/Back.pressed.connect(back_to_menu)
	$Panel/Content/Level1.grab_focus()

func open_level_one() -> void:
	if opening: return
	opening = true
	var error = get_tree().change_scene_to_packed(level_one)
	if error != OK:
		opening = false
		$Panel/Content/Description.text = "Kunne ikke åpne nivået. Prøv igjen."

func back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back_to_menu()
		get_viewport().set_input_as_handled()
