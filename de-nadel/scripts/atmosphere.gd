extends Control

var elapsed = 0.0
var particles: Array[Vector3] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng = RandomNumberGenerator.new()
	rng.seed = 1937
	for i in range(42):
		particles.append(Vector3(rng.randf(), rng.randf(), rng.randf_range(0.3, 1.0)))
	GameSettings.changed.connect(_settings_changed)
	_settings_changed()

func _settings_changed() -> void:
	set_process(not GameSettings.reduced_motion)
	queue_redraw()

func _process(dt: float) -> void:
	elapsed += dt
	queue_redraw()

func _draw() -> void:
	if GameSettings.reduced_motion: return
	var pivot = size * Vector2(0.825, 0.43)
	var angle = -1.9 + sin(elapsed * 0.14) * 0.45
	var reach = size.y * 0.8
	var points = PackedVector2Array([pivot, pivot + Vector2.from_angle(angle - 0.065) * reach, pivot + Vector2.from_angle(angle + 0.065) * reach])
	draw_colored_polygon(points, Color(0.85, 0.87, 0.82, 0.025))
	for i in range(particles.size()):
		var p = particles[i]
		var x = fposmod(p.x + sin(elapsed * 0.2 + i) * 0.008 + elapsed * 0.003 * p.z, 1.0)
		var y = fposmod(p.y - elapsed * 0.012 * p.z, 1.0)
		var alpha = (0.12 + 0.12 * sin(elapsed * 0.6 + i)) * p.z
		draw_circle(Vector2(x, y) * size, p.z * 1.5, Color(0.8, 0.53, 0.37, alpha))
