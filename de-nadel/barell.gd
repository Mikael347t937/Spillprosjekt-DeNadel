
extends Node2D

var bullet = preload("res://bullet.tscn")

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("ui_accept"):
		shoot()

func shoot() -> void:
	var instance = bullet.instantiate()

	get_tree().current_scene.add_child(instance)

	instance.global_position = global_position
	instance.global_rotation = global_rotation
	instance.linear_velocity = Vector2.RIGHT.rotated(global_rotation) * instance.speed
