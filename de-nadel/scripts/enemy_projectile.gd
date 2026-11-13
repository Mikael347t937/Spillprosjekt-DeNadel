extends Area2D

@export var speed = 300.0
@export var damage = 15
var direction = Vector2.RIGHT
var lifetime = 4.0
var spent = false

func _ready() -> void:
	body_entered.connect(hit_body)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0: queue_free()

func hit_body(body: Node) -> void:
	if spent: return
	spent = true
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
