@tool # Gjør at koden kjører i editoren
extends Control # Bruker en Control-node

func _ready() -> void: # Kjører når objektet er klart
	resized.connect(queue_redraw) # Tegner på nytt når størrelsen endres

func _draw() -> void: # Tegner våpenet
	var red = Color("a62b26") # Lager en rød farge
	var x = size.x * 0.5 # Finner midten av bredden
	var h = size.y # Henter høyden

	draw_line(Vector2(x, 0), Vector2(x, h * 0.28), Color("dbd0bd"), 2) # Tegner toppen
	draw_rect(Rect2(x - 3, h * 0.22, 6, h * 0.11), red) # Tegner en liten del
	draw_rect(Rect2(x - 15, h * 0.30, 30, h * 0.43), red) # Tegner hoveddelen
	draw_rect(Rect2(x - 12, h * 0.34, 4, h * 0.32), red.lightened(0.18)) # Tegner en lysere detalj

	for i in range(5): # Gjentar tegningen fem ganger
		var y = h * (0.37 + i * 0.064) # Bestemmer plasseringen
		draw_line(Vector2(x + 7, y), Vector2(x + 15, y), Color("41171a"), 3) # Tegner små streker

	draw_rect(Rect2(x - 24, h * 0.72, 48, 5), red) # Tegner en vannrett del
	draw_rect(Rect2(x - 4, h * 0.75, 8, h * 0.18), red) # Tegner håndtaket
	draw_rect(Rect2(x - 17, h * 0.92, 34, 5), red) # Tegner bunnen av håndtaket
