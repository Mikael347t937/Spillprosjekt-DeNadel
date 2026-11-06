
extends CharacterBody2D

var speed = 200

func _physics_process(delta: float) -> void:
	var move_direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		move_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		move_direction.y -= 1

	move_direction = move_direction.normalized()

	velocity.x = move_toward(velocity.x, move_direction.x * speed, 5)
	velocity.y = move_toward(velocity.y, move_direction.y * speed, 5)

	move_and_slide()
