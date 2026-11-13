extends CharacterBody2D

signal health_changed(current: int, maximum: int)

const SKINS = [preload("res://assets/characters/guard.tres"), preload("res://assets/characters/scout.tres"), preload("res://assets/characters/soldier.tres")]
@export_enum("Vakt", "Speider", "Soldat") var appearance = 0
@export var custom_frames: SpriteFrames
@export var body_tint = Color.WHITE
var hit_flash = 0.0

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
	$Sprite2D.sprite_frames = custom_frames if custom_frames else SKINS[appearance]
	$Sprite2D.modulate = body_tint
	health = max_health
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	target = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	hit_flash = maxf(0, hit_flash - delta)
	$Sprite2D.modulate = Color(2, 0.6, 0.6) if hit_flash > 0 else body_tint
	if velocity.length() > 1:
		$Sprite2D.flip_h = velocity.x < 0
		$Sprite2D.play("walk")
	else:
		$Sprite2D.stop()

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
	if attack_timer > 0 or not is_instance_valid(target) or not target.has_method("take_damage"): return
	# A box or wall between the two characters blocks the attack.
	var ray = PhysicsRayQueryParameters2D.create(global_position, target.global_position, 2)
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): return
	target.take_damage(attack_damage)
	attack_timer = attack_interval

func take_damage(amount: int) -> void:
	if dead or amount <= 0: return
	health = maxi(0, health - amount)
	$HealthBar.value = health
	hit_flash = 0.12
	health_changed.emit(health, max_health)
	if health == 0:
		dead = true
		queue_free()
