extends Area2D # Registrerer kollisjoner

@export_enum("Mynt", "Patroner", "Hagle") var pickup_type = 0 # Type gjenstand
@export_range(1, 100) var amount = 1 # Antall spilleren får
var collected = false # Sjekker om den er plukket opp

func _ready() -> void: # Kjører når objektet starter
	body_entered.connect(collect) # Kobler kollisjon til collect
	$Sprite2D.play("spin") # Starter spinn-animasjonen

func collect(body: Node) -> void: # Kjører ved treff
	if collected or not body.is_in_group("player"): return # Sjekker om det er spilleren

	if not body.collect_pickup(pickup_type, amount): return # Gir spilleren gjenstanden

	GameAudio.play_effect(GameAudio.PICKUP, -14.0) # Spiller av plukkelyd
	collected = true # Marker som plukket opp
	$Sprite2D.hide() # Skjuler gjenstanden
	queue_free() # Sletter gjenstanden
