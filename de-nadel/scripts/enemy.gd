extends CharacterBody2D

@export var speed: float = 95.0
@export_range(1, 100) var max_health: int = 3
@export var detection_radius: float = 650.0
@export var stopping_distance: float = 64.0
var health: int
var dead: bool = false
var target: Node2D

func _ready() -> void:
	health = max_health
	target = get_tree().get_first_node_in_group("player") as Node2D

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	if dead: return
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(target):
		var direction = target.global_position - global_position
		if direction.length() <= detection_radius and direction.length() > stopping_distance:
			velocity = direction.normalized() * speed
	move_and_slide()

func take_damage(amount: int) -> void:
	if dead or amount <= 0: return
	health = maxi(0, health - amount)
	if health == 0:
		dead = true
		queue_free()
