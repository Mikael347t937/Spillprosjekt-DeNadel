extends Node2D

var bullet = preload("res://bullet.tscn")
var ready_to_shoot = false
var cooldown = 0.0

func _process(delta: float) -> void:
	cooldown = maxf(0, cooldown - delta)
	if get_parent().dead or get_parent().controls_locked: return
	if Input.is_action_just_pressed("weapon_pistol"): get_parent().select_weapon(0)
	if Input.is_action_just_pressed("weapon_shotgun"): get_parent().select_weapon(1)
	if not ready_to_shoot:
		ready_to_shoot = not Input.is_action_pressed("shoot")
		return
	look_at(get_global_mouse_position())
	$Weapon.visible = get_parent().selected_weapon == 1 and get_parent().has_shotgun
	$Weapon.flip_v = absf(wrapf(global_rotation, -PI, PI)) > PI / 2
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	var player = get_parent()
	if player.dead or player.controls_locked or get_tree().paused or cooldown > 0: return
	var shotgun = player.selected_weapon == 1 and player.has_shotgun and player.shells > 0
	cooldown = 0.65 if shotgun else 0.22
	for spread in [-0.09, 0.0, 0.09] if shotgun else [0.0]:
		var instance = bullet.instantiate()
		get_tree().current_scene.add_child(instance)
		instance.global_position = $Muzzle.global_position
		instance.global_rotation = global_rotation + spread
		instance.linear_velocity = Vector2.RIGHT.rotated(instance.global_rotation) * instance.speed
	if shotgun:
		player.shells -= 1
		if player.shells == 0: player.selected_weapon = 0
		player.inventory_changed.emit()
