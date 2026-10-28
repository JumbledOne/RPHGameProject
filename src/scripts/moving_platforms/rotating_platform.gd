@tool
class_name RotatingPlatform
extends BaseMovingPlatform

## Rotation speed in degrees per second.
@export var rotation_speed: float = 90.0

func _physics_process(delta: float) -> void:
	rotate(deg_to_rad(rotation_speed) * delta)
