class_name FloatingPlatform
extends MovingPlatform
## A safe horizontal platform that also bobs around its placed height.

@export_range(0.0, 64.0) var bob_height: float = 8.0
@export_range(0.1, 20.0) var bob_period: float = 2.5
@export_range(0.0, 1.0) var bob_phase: float = 0.0

var _elapsed: float = 0.0
var _origin_y: float

func _ready() -> void:
	super()
	_origin_y = position.y

func _physics_process(delta: float) -> void:
	# AnimatableBody2D defers synchronized position changes until the physics step.
	# Write once so bobbing does not overwrite the pending horizontal movement.
	var next_position := position
	if enabled and moving:
		next_position += direction * speed * delta
	_elapsed += delta
	next_position.y = _origin_y + sin((_elapsed / maxf(bob_period, 0.1) + bob_phase) * TAU) * bob_height
	position = next_position
