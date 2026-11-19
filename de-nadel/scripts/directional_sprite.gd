extends AnimatedSprite2D

# Side art faces left. Sheets without a side view keep the front view sideways.
func update_motion(motion: Vector2, facing_hint: Vector2 = Vector2.ZERO) -> void:
	var moving = motion.length_squared() > 0.01
	var direction = motion if moving else facing_hint
	if direction.length_squared() > 0.01:
		if absf(direction.x) > absf(direction.y):
			animation = &"side" if sprite_frames.has_animation(&"side") else &"front"
			flip_h = animation == &"side" and direction.x > 0
		else:
			animation = &"back" if direction.y < 0 else &"front"
			flip_h = false
	if moving:
		play()
	else:
		stop()
		frame = 0
