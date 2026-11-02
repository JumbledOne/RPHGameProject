class_name FloatingPlatform
extends HazardPlatform
## A side-damaging platform that also bobs around its placed height.

@export_range(0.0, 64.0) var bob_height: float = 8.0
@export_range(0.1, 20.0) var bob_period: float = 2.5
@export_range(0.0, 1.0) var bob_phase: float = 0.0

func _motion_offset() -> Vector2:
	var bob := sin((_elapsed / maxf(bob_period, 0.1) + bob_phase) * TAU)
	return super() + Vector2(0, bob * bob_height)
