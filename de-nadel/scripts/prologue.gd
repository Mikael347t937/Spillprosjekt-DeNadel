extends Control # Bruker en Control-node

var returning = false # Sjekker om spilleren allerede går tilbake til menyen

func _ready() -> void: # Kjører når scenen starter
	$Content/Back.pressed.connect(return_to_menu) # Kobler tilbake-knappen til funksjonen
	$Content/Back.grab_focus() # Gir tilbake-knappen fokus
	$Fade.color.a = 1 # Starter med svart skjerm

	if GameSettings.reduced_motion: # Sjekker om redusert bevegelse er aktivert
		$Fade.color.a = 0 # Fjerner den svarte skjermen
	else:
		create_tween().tween_property($Fade, "color:a", 0.0, 0.65) # Lager en myk overgang til synlig skjerm

func return_to_menu() -> void: # Funksjon som går tilbake til hovedmenyen
	if returning: return # Stopper hvis man allerede er på vei tilbake
	returning = true # Marker at man er på vei tilbake
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") # Bytter til hovedmenyen

func _unhandled_key_input(event: InputEvent) -> void: # Sjekker tastetrykk som ikke er håndtert
	if event.is_action_pressed("ui_cancel"): return_to_menu() # Går tilbake til menyen hvis man trykker Escape
