extends CharacterBody2D

@export var speed: float = 95.0
@export_range(1, 100) var max_health: int = 3
@export var detection_radius: float = 650.0
@export var stopping_distance: float = 64.0
@export var attack_damage: int = 20
@export var attack_interval: float = 1.0
var health: int
var dead = false
var target: Node2D
var attack_timer = 0.0

func _ready() -> void:
	health = max_health
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	target = get_tree().get_first_node_in_group("player") as Node2D

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if dead: return
	attack_timer = maxf(0, attack_timer - delta)
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(target):
		var direction = target.global_position - global_position
		if direction.length() <= detection_radius and direction.length() > stopping_distance:
			velocity = direction.normalized() * speed
		elif direction.length() <= stopping_distance + 8:
			try_attack()
	move_and_slide()

func try_attack() -> void:
	if attack_timer > 0 or not target.has_method("take_damage"): return
	# A box or wall between the two characters blocks the attack.
	var ray = PhysicsRayQueryParameters2D.create(global_position, target.global_position, 2)
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): return
	target.take_damage(attack_damage)
	attack_timer = attack_interval

func take_damage(amount: int) -> void:
	if dead or amount <= 0: return
	health = maxi(0, health - amount)
	$HealthBar.value = health
	if health == 0:
		dead = true
		queue_free()
