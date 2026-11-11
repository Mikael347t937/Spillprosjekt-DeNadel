extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

@export var speed: float = 200.0
@export var acceleration: float = 300.0
@export var max_health: int = 100
var health: int
var dead = false
var hit_cooldown = 0.0

func _ready() -> void:
	health = max_health
	update_health_bar()

func _physics_process(delta: float) -> void:
	if dead: return
	hit_cooldown = maxf(0, hit_cooldown - delta)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	move_and_slide()

func take_damage(amount: int) -> void:
	if dead or amount <= 0 or hit_cooldown > 0: return
	health = maxi(0, health - amount)
	hit_cooldown = 0.5
	update_health_bar()
	health_changed.emit(health, max_health)
	if health == 0:
		dead = true
		velocity = Vector2.ZERO
		died.emit()

func update_health_bar() -> void:
	$HealthBar.max_value = max_health
	$HealthBar.value = health
