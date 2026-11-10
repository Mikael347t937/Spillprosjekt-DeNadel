
extends CharacterBody2D

@export var speed = 100.0

var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var direction = global_position.direction_to(player.global_position)

	velocity = direction * speed
	move_and_slide()
