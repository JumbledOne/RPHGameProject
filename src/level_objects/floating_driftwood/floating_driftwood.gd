extends FloatingPlatform
## Reuse moving driftwood after both it and its placed origin leave the view.

var _origin_transform: Transform2D

func _ready() -> void:
	_origin_transform = transform
	super()

func _physics_process(delta: float) -> void:
	# Re-arm screen activation after a reset, including the bobbing motion.
	if not enabled:
		if not _is_on_screen(transform):
			return
		enable_movement()
	super(delta)
	var has_horizontal_motion := moving and not is_zero_approx(speed * direction.x)
	if not has_horizontal_motion and is_zero_approx(bob_height):
		return
	if _is_on_screen(transform) or _is_on_screen(_origin_transform):
		return
	position = _origin_transform.origin
	_elapsed = 0.0
	enabled = false

func _is_on_screen(local_transform: Transform2D) -> bool:
	# Keep the origin attached to its parent and account for camera, zoom and rotation.
	var parent_to_screen := get_global_transform_with_canvas() * transform.affine_inverse()
	var sprite: Sprite2D = $Sprite2D
	var bounds := parent_to_screen * local_transform * sprite.transform * sprite.get_rect()
	return get_viewport_rect().intersects(bounds)
