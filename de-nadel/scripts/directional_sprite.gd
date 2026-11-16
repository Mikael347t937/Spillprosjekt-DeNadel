extends AnimatedSprite2D

# Both supplied side views face left. Only the side animation is mirrored.
func update_motion(motion: Vector2, facing_hint: Vector2 = Vector2.ZERO) -> void:
	var moving = motion.length_squared() > 0.01
	var direction = motion if moving else facing_hint
	if direction.length_squared() > 0.01:
		if absf(direction.x) > absf(direction.y):
			animation = &"side"
			flip_h = direction.x > 0
		else:
			animation = &"back" if direction.y < 0 else &"front"
			flip_h = false
	if moving:
		play()
	else:
		stop()
		frame = 0
