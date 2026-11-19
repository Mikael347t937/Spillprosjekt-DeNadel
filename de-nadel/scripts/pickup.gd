extends Area2D

@export_enum("Mynt", "Patroner", "Hagle") var pickup_type = 0
@export_range(1, 100) var amount = 1
var collected = false

func _ready() -> void:
	body_entered.connect(collect)
	$Sprite2D.play("spin")

func collect(body: Node) -> void:
	if collected or not body.is_in_group("player"): return
	if not body.collect_pickup(pickup_type, amount): return
	collected = true
	$Sprite2D.hide()
	queue_free()
