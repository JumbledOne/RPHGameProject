extends SceneTree

var failures := 0

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var box = load("res://scripts/tree_box/tree_box.tscn").instantiate()
	box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	box.size = Vector2(640, 360)
	root.add_child(box)
	await process_frame
	await process_frame
	var mesh: MultiMesh = box.multi_mesh.multimesh
	check(mesh.instance_count == 22, "Both edges must have trees across the full width")
	var original := mesh.get_instance_transform_2d(0)
	for i in range(mesh.instance_count):
		var t := mesh.get_instance_transform_2d(i)
		var edge_y := 0.0 if i < 11 else 360.0
		check(absf(t.origin.y - edge_y) <= 16.0, "Trees must stay along the top or bottom edge")
		check(t.x.length() >= 79.99 and t.x.length() <= 128.01, "Tree width must respect configured range")
	box.seed = 0
	await process_frame
	check(box.multi_mesh.multimesh.get_instance_transform_2d(0).is_equal_approx(original), "Same seed must reproduce the preview")
	box.seed = 42
	await process_frame
	check(not box.multi_mesh.multimesh.get_instance_transform_2d(0).is_equal_approx(original), "New seed must change trees")
	box.size = Vector2(128, 100)
	await process_frame
	check(box.multi_mesh.multimesh.instance_count == 6, "Resizing must refresh trees")
	check(box.get_child_count(true) == 1, "Regeneration must reuse its generated child")
	check(box.multi_mesh.owner == null, "Preview must not be serialized into scenes")
	box.tree_tex = null
	await process_frame
	check(box.multi_mesh.multimesh.instance_count == 0, "Removing texture must clear preview")
	box.free()
	print("Tree box checks: ", failures, " failures; editor=", Engine.is_editor_hint())
	quit(failures)
