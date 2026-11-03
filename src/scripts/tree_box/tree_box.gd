@tool
extends Control

@export var tree_tex: Texture2D:
	set(value):
		tree_tex = value
		_queue_generate()
@export var seed: int = 0:
	set(value):
		seed = value
		_queue_generate()

const SPACING: float = 64
const RANDOMNESS_X: float = 32
const RANDOMNESS_Y: float = 16
const RANDOMNESS_ROT: float = 2

const MAX_TREE_WIDTH: float = 128 # Using the texture size in px
const MIN_TREE_WIDTH: float = 80


var multi_mesh: MultiMeshInstance2D
var _generation_queued: bool = false


func _ready() -> void:
	if not resized.is_connected(_queue_generate):
		resized.connect(_queue_generate)
	_queue_generate()


func _queue_generate() -> void:
	if not is_inside_tree() or _generation_queued:
		return
	_generation_queued = true
	_generate.call_deferred()


func _generate() -> void:
	_generation_queued = false
	if not is_inside_tree():
		return
	if not is_instance_valid(multi_mesh):
		multi_mesh = MultiMeshInstance2D.new()
		multi_mesh.name = "GeneratedTrees"
		# Leave ownership unset: preview trees are regenerated, not saved.
		add_child(multi_mesh, false, Node.INTERNAL_MODE_BACK)

	multi_mesh.texture = tree_tex
	var mesh := MultiMesh.new()
	mesh.transform_format = MultiMesh.TRANSFORM_2D
	multi_mesh.multimesh = mesh
	if tree_tex == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var texture_size := tree_tex.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var quad := QuadMesh.new()
	quad.size = Vector2(1.0, texture_size.y / texture_size.x)
	mesh.mesh = quad
	var intervals := maxi(1, ceili(size.x / SPACING))
	var trees_per_edge := intervals + 1
	mesh.instance_count = trees_per_edge * 2
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for edge in range(2):
		for index in range(trees_per_edge):
			var x := size.x * float(index) / float(intervals)
			# Keep the corner trees on the corners to cover the full edge.
			if index > 0 and index < intervals:
				x += rng.randf_range(-RANDOMNESS_X, RANDOMNESS_X)
			var y := float(edge) * size.y + rng.randf_range(-RANDOMNESS_Y, RANDOMNESS_Y)
			var width := rng.randf_range(MIN_TREE_WIDTH, MAX_TREE_WIDTH)
			var angle := rng.randf_range(-RANDOMNESS_ROT, RANDOMNESS_ROT)
			var transform := Transform2D(angle, Vector2(width, width), 0.0, Vector2(x, y))
			mesh.set_instance_transform_2d(edge * trees_per_edge + index, transform)
