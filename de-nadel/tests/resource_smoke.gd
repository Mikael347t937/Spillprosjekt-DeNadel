extends SceneTree

var failures = 0
var checked = 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var main_scene = str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene.is_empty() or ResourceLoader.load(main_scene) == null:
		push_error("Project main scene cannot be loaded: " + main_scene)
		failures += 1
	validate_directory("res://")
	print("RESOURCE CHECKS: %d scenes/resources checked, %d failed" % [checked, failures])
	quit(1 if failures else 0)

func validate_directory(path: String) -> void:
	var directory = DirAccess.open(path)
	if directory == null:
		push_error("Cannot open resource directory: " + path)
		failures += 1
		return
	for child in directory.get_directories():
		if not child.begins_with(".") and child != "captures":
			validate_directory(path.path_join(child))
	for filename in directory.get_files():
		if filename.get_extension() not in ["tscn", "tres"]: continue
		var resource_path = path.path_join(filename)
		checked += 1
		if ResourceLoader.load(resource_path) == null:
			push_error("Scene/resource or one of its dependencies is broken: " + resource_path)
			failures += 1
		else:
			print("PASS: " + resource_path)
