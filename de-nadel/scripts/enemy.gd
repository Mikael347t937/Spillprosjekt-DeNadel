extends CharacterBody2D

signal health_changed(current: int, maximum: int)

const FRAMES = preload("res://assets/characters/syringe_enemy.tres")
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
@export var windup_duration = 0.35
var windup_left = 0.0
var winding_up = false
var path = PackedVector2Array()
var path_time = 0.0

func _ready() -> void:
	$Sprite2D.sprite_frames = custom_frames if custom_frames else FRAMES
	$Sprite2D.modulate = body_tint
	health = max_health
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	target = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	hit_flash = maxf(0, hit_flash - delta)
	$Sprite2D.modulate = Color(2, 0.6, 0.6) if hit_flash > 0 else body_tint

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if dead: return
	if winding_up:
		windup_left -= delta
		if windup_left <= 0:
			winding_up = false
			$AttackTell.hide()
			if is_instance_valid(target) and global_position.distance_to(target.global_position) <= stopping_distance + 20: try_attack()
			attack_timer = attack_interval
		$Sprite2D.update_motion(Vector2.ZERO)
		return
	attack_timer = maxf(0, attack_timer - delta)
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(target):
		var direction = target.global_position - global_position
		if direction.length() <= detection_radius and direction.length() > stopping_distance:
			velocity = chase_direction(direction, delta) * speed
		elif direction.length() <= stopping_distance + 8:
			if attack_timer <= 0:
				winding_up = true
				windup_left = windup_duration
				$AttackTell.show()
	var before = global_position
	move_and_slide()
	var facing = target.global_position - global_position if is_instance_valid(target) else Vector2.ZERO
	$Sprite2D.update_motion(global_position - before, facing)

func chase_direction(to_player: Vector2, delta: float) -> Vector2:
	var side = to_player.normalized().orthogonal() * 23
	var clear = true
	for offset in [Vector2.ZERO, side, -side]:
		var ray = PhysicsRayQueryParameters2D.create(global_position + offset, target.global_position + offset, 2)
		if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): clear = false
	if clear: return to_player.normalized()
	var navigation = get_tree().get_first_node_in_group("path_grid")
	if not navigation: return to_player.normalized()
	path_time -= delta
	if path_time <= 0:
		path = navigation.route(global_position, target.global_position)
		path_time = 0.35
	while not path.is_empty() and global_position.distance_to(path[0]) < 12: path.remove_at(0)
	return global_position.direction_to(path[0]) if not path.is_empty() else Vector2.ZERO

func try_attack() -> void:
	if attack_timer > 0 or not is_instance_valid(target) or not target.has_method("take_damage"): return
	# A box or wall between the two characters blocks the attack.
	var ray = PhysicsRayQueryParameters2D.create(global_position, target.global_position, 2)
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): return
	target.take_damage(attack_damage)
	attack_timer = attack_interval

func take_damage(amount: int) -> void:
	if dead or amount <= 0: return
	GameAudio.play_effect(GameAudio.IMPACT, -12.0)
	health = maxi(0, health - amount)
	$HealthBar.value = health
	hit_flash = 0.12
	health_changed.emit(health, max_health)
	if health == 0:
		dead = true
		queue_free()
