extends Node2D

var bullet = preload("res://bullet.tscn")
var ready_to_shoot = false

func _process(_delta: float) -> void:
	if get_parent().dead: return
	if not ready_to_shoot:
		ready_to_shoot = not Input.is_action_pressed("shoot")
		return
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if get_parent().dead or get_tree().paused: return
	var instance = bullet.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = global_position
	instance.global_rotation = global_rotation
	instance.linear_velocity = Vector2.RIGHT.rotated(global_rotation) * instance.speed
