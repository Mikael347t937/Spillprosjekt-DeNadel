extends Control

var returning = false

func _ready() -> void:
	$Content/Back.pressed.connect(return_to_menu)
	$Content/Back.grab_focus()
	$Fade.color.a = 1
	if GameSettings.reduced_motion:
		$Fade.color.a = 0
	else:
		create_tween().tween_property($Fade, "color:a", 0.0, 0.65)

func return_to_menu() -> void:
	if returning: return
	returning = true
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): return_to_menu()
