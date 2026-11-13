extends "res://scripts/enemy.gd"

const PROJECTILE = preload("res://scenes/enemy_projectile.tscn")
@export var shot_warning = 0.75
@export var dash_warning = 0.9
@export var dash_speed = 650.0
@export var dash_duration = 0.4
@export var recovery_time = 1.1
var state = "move"
var state_time = 1.5
var attack_direction = Vector2.RIGHT
var shots_left = 0
var next_is_dash = false
var second_phase = false

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if dead or not is_instance_valid(target): return
	state_time -= delta
	attack_timer = maxf(0, attack_timer - delta)
	match state:
		"move":
			var to_player = target.global_position - global_position
			if to_player.length() > 300: velocity = to_player.normalized() * speed
			if state_time <= 0: prepare_attack()
		"aim":
			if state_time <= 0:
				$Warning.hide()
				state = "shoot"
				shots_left = 3
				state_time = 0
		"shoot":
			if state_time <= 0:
				fire()
				shots_left -= 1
				state_time = 0.22
				if shots_left == 0: rest()
		"charge":
			if state_time <= 0:
				$Warning.hide()
				state = "dash"
				state_time = dash_duration
		"dash":
			velocity = attack_direction * dash_speed
			if global_position.distance_to(target.global_position) < 85: try_attack()
			if state_time <= 0: rest()
		"rest":
			if state_time <= 0:
				state = "move"
				state_time = 0.45
	move_and_slide()
	if state == "dash" and get_slide_collision_count() > 0: rest()

func prepare_attack() -> void:
	attack_direction = (target.global_position - global_position).normalized()
	if attack_direction == Vector2.ZERO: attack_direction = Vector2.RIGHT
	$Warning.points = PackedVector2Array([Vector2.ZERO, attack_direction * 260])
	$Warning.show()
	state = "charge" if next_is_dash else "aim"
	state_time = dash_warning if next_is_dash else shot_warning
	if second_phase: state_time *= 0.75
	next_is_dash = not next_is_dash

func fire() -> void:
	var shot = PROJECTILE.instantiate()
	shot.direction = attack_direction
	shot.position = position + attack_direction * 55
	get_parent().add_child(shot)

func rest() -> void:
	velocity = Vector2.ZERO
	state = "rest"
	state_time = recovery_time * (0.75 if second_phase else 1.0)
	$Warning.hide()

func take_damage(amount: int) -> void:
	super.take_damage(amount)
	if not dead and health <= max_health / 2.0: second_phase = true
