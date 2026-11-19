extends Node

# Saved only when moving to the next level. Restart restores that starting point.
var coins = 0
var shells = 0
var has_shotgun = false
var selected_weapon = 0

func reset() -> void:
	coins = 0
	shells = 0
	has_shotgun = false
	selected_weapon = 0

func save_player(player: Node) -> void:
	coins = player.coins
	shells = player.shells
	has_shotgun = player.has_shotgun
	selected_weapon = player.selected_weapon

func apply_to_player(player: Node) -> void:
	player.coins = coins
	player.shells = shells
	player.has_shotgun = has_shotgun
	player.selected_weapon = selected_weapon
