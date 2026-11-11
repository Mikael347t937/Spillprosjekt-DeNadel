extends RigidBody2D

@export var speed: float = 800.0
@export var damage: int = 1
@export var lifetime: float = 3.0
var spent: bool = false

func _ready() -> void:
	gravity_scale = 0.0
	contact_monitor = true
	max_contacts_reported = 4
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	body_entered.connect(_on_body_entered)
	linear_velocity = Vector2.RIGHT.rotated(global_rotation) * speed

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
	linear_velocity = Vector2.RIGHT.rotated(global_rotation) * speed

func _on_body_entered(body: Node) -> void:
	if spent: return
	spent = true
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
