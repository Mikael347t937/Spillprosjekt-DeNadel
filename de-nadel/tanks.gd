extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal inventory_changed
signal died

@export var speed: float = 200.0
@export var acceleration: float = 300.0
@export var max_health: int = 100
var coins = 0
var shells = 0
var has_shotgun = false
var selected_weapon = 0
var controls_locked = false
var health: int
var dead = false
var hit_cooldown = 0.0

func _ready() -> void:
	RunInventory.apply_to_player(self)
	health = max_health
	update_health_bar()

func _physics_process(delta: float) -> void:
	if dead or controls_locked: return
	hit_cooldown = maxf(0, hit_cooldown - delta)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	var before = global_position
	move_and_slide()
	$Sprite2D.update_motion(global_position - before, direction)

func take_damage(amount: int) -> void:
	if dead or controls_locked or amount <= 0 or hit_cooldown > 0: return
	health = maxi(0, health - amount)
	hit_cooldown = 0.5
	update_health_bar()
	health_changed.emit(health, max_health)
	if health == 0:
		dead = true
		velocity = Vector2.ZERO
		$Sprite2D.update_motion(Vector2.ZERO)
		died.emit()

func update_health_bar() -> void:
	$HealthBar.max_value = max_health
	$HealthBar.value = health

func collect_pickup(kind: int, amount: int) -> bool:
	if dead or controls_locked: return false
	match kind:
		0: coins += amount
		1: shells += amount
		2:
			has_shotgun = true
			shells += amount
			selected_weapon = 1
	inventory_changed.emit()
	return true

func select_weapon(index: int) -> void:
	if dead or controls_locked: return
	if index == 1 and (not has_shotgun or shells <= 0): return
	selected_weapon = index
	inventory_changed.emit()

func begin_ending() -> void:
	controls_locked = true
	velocity = Vector2.ZERO
	$Sprite2D.update_motion(Vector2.ZERO)
