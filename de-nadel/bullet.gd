
extends RigidBody2D

var speed = 800.0

func _ready() -> void:
	gravity_scale = 0.0

func _physics_process(delta: float) -> void:
	linear_velocity = Vector2.RIGHT.rotated(global_rotation) * speed
