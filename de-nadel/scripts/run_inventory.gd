extends Node # Gjør at koden fungerer som en vanlig Node i Godot

# Variabler som lagrer spillerens verdier
var coins = 0 # Antall mynter spilleren har
var shells = 0 # Antall skudd spilleren har
var has_shotgun = false # Sjekker om spilleren har hagle
var selected_weapon = 0 # Hvilket våpen spilleren har valgt

func reset() -> void:
	# Nullstiller alle verdiene til startverdiene
	coins = 0
	shells = 0
	has_shotgun = false
	selected_weapon = 0

func save_player(player: Node) -> void:
	# Lagrer spillerens verdier i dette scriptet
	coins = player.coins
	shells = player.shells
	has_shotgun = player.has_shotgun
	selected_weapon = player.selected_weapon

func apply_to_player(player: Node) -> void:
	# Overfører de lagrede verdiene tilbake til spilleren
	player.coins = coins
	player.shells = shells
	player.has_shotgun = has_shotgun
	player.selected_weapon = selected_weapon
