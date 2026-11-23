extends Area2D # Gir kulen en usynlig kollisjonssensor

@export var speed = 300.0 # Fart
@export var damage = 15   # Skade

var direction = Vector2.RIGHT # Retning (mot høyre)
var lifetime = 4.0            # Levetid i sekunder
var spent = false             # Har kulen allerede truffet noe?

func _ready() -> void:
	body_entered.connect(hit_body) # Si fra til hit_body når sensoren treffer noe

func _physics_process(delta: float) -> void:
	position += direction * speed * delta # Flytt kulen fremover
	lifetime -= delta                     # Tell ned levetiden
	if lifetime <= 0:
		queue_free()                      # Slett kulen når tiden er ute

func hit_body(body: Node) -> void:
	if spent: return # Stopp hvis den allerede har truffet
	spent = true     # Marker som brukt opp
	
	# Gi skade hvis vi traff spilleren
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		
	queue_free() # Slett kulen
