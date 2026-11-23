extends Area2D

var collected = false

func _ready() -> void:
	body_entered.connect(collect)

func collect(body: Node) -> void:
	if collected or get_tree().paused or not body.is_in_group("player") or body.dead: return
	collected = true
	get_parent().supplies_collected = true
	GameAudio.play_effect(GameAudio.PICKUP, -10.0)
	hide()
	queue_free()
