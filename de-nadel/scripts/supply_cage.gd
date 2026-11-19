extends StaticBody2D

signal released

const SYRINGES = [preload("res://assets/items/syringe.tres"), preload("res://assets/items/syringe_alt.tres")]
@export_range(1, 60) var syringe_count = 24
var opening = false
var opened = false

func release_supplies() -> void:
	if opening or opened: return
	opening = true
	$VictoryMusic.play()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.play("open")
	await get_tree().create_timer(0.45, false).timeout
	if not is_inside_tree(): return
	for i in range(syringe_count):
		var syringe = Sprite2D.new()
		syringe.texture = SYRINGES[i % 2]
		syringe.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		syringe.scale = Vector2(0.15, 0.15)
		syringe.position = Vector2(randf_range(-20, 20), 5)
		$Spilled.add_child(syringe)
		var landing = Vector2(randf_range(-115, 80), randf_range(65, 130))
		var arc = create_tween()
		arc.tween_property(syringe, "position", Vector2(landing.x * 0.5, -55), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		arc.tween_property(syringe, "position", landing, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		var spin = create_tween()
		spin.tween_property(syringe, "rotation", randf_range(-2.2, 2.2), 0.9)
	await get_tree().create_timer(1.6, false).timeout
	if not is_inside_tree(): return
	opened = true
	opening = false
	released.emit()
