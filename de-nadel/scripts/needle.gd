@tool
extends Control

func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	var red = Color("a62b26")
	var x = size.x * 0.5
	var h = size.y
	draw_line(Vector2(x, 0), Vector2(x, h * 0.28), Color("dbd0bd"), 2)
	draw_rect(Rect2(x - 3, h * 0.22, 6, h * 0.11), red)
	draw_rect(Rect2(x - 15, h * 0.30, 30, h * 0.43), red)
	draw_rect(Rect2(x - 12, h * 0.34, 4, h * 0.32), red.lightened(0.18))
	for i in range(5):
		var y = h * (0.37 + i * 0.064)
		draw_line(Vector2(x + 7, y), Vector2(x + 15, y), Color("41171a"), 3)
	draw_rect(Rect2(x - 24, h * 0.72, 48, 5), red)
	draw_rect(Rect2(x - 4, h * 0.75, 8, h * 0.18), red)
	draw_rect(Rect2(x - 17, h * 0.92, 34, 5), red)
