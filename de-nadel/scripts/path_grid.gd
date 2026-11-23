extends Node2D

var grid = AStarGrid2D.new()
var ready_for_paths = false

func _ready() -> void:
	add_to_group("path_grid")
	grid.region = Rect2i(0, 0, 50, 28)
	grid.cell_size = Vector2(32, 32)
	grid.offset = Vector2(16, 16)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	await get_tree().physics_frame
	if not is_inside_tree(): return
	var clearance = CircleShape2D.new()
	clearance.radius = 23
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = clearance
	query.collision_mask = 2
	for y in range(grid.region.size.y):
		for x in range(grid.region.size.x):
			var cell = Vector2i(x, y)
			query.transform = Transform2D(0, grid.get_point_position(cell))
			grid.set_point_solid(cell, not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty())
	ready_for_paths = true

func nearest_cell(point: Vector2) -> Vector2i:
	var cell = Vector2i(((point - grid.offset) / grid.cell_size).round())
	cell.x = clampi(cell.x, 0, grid.region.size.x - 1)
	cell.y = clampi(cell.y, 0, grid.region.size.y - 1)
	if not grid.is_point_solid(cell): return cell
	for radius in range(1, 7):
		for y in range(-radius, radius + 1):
			for x in range(-radius, radius + 1):
				var candidate = cell + Vector2i(x, y)
				if grid.is_in_boundsv(candidate) and not grid.is_point_solid(candidate): return candidate
	return cell

func open_spawn(point: Vector2) -> Vector2:
	return grid.get_point_position(nearest_cell(point))

func route(from: Vector2, to: Vector2) -> PackedVector2Array:
	if not ready_for_paths: return PackedVector2Array()
	return grid.get_point_path(nearest_cell(from), nearest_cell(to))
