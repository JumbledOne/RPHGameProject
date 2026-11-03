class_name HazardPlatform
extends MovingPlatform
## The top and underside are solid; only the two side strips deal damage.

const CONTACT_HAZARD = preload("res://scripts/level_objects/static_hazard.gd")

@export_range(0, 10) var side_damage: int = 1
@export_range(0.1, 5.0) var damage_interval: float = 1.0
@export var side_knockback: Vector2 = Vector2(180, -80)

func _ready() -> void:
	super()
	var collider := get_node_or_null("CollisionShape2D")
	if collider == null:
		push_error("HazardPlatform requires a CollisionShape2D node.")
		return
	var bounds: Rect2
	var side_ranges := [Vector2.ZERO, Vector2.ZERO]
	if collider is CollisionShape2D and collider.shape is RectangleShape2D:
		var rectangle := collider.shape as RectangleShape2D
		bounds = Rect2(collider.position - rectangle.size / 2.0, rectangle.size)
		for index in 2:
			side_ranges[index] = Vector2(bounds.position.y, bounds.end.y)
	elif collider is CollisionPolygon2D:
		var polygon := collider as CollisionPolygon2D
		if polygon.polygon.size() < 3:
			push_error("HazardPlatform CollisionPolygon2D must contain at least three points.")
			return
		bounds = Rect2(polygon.polygon[0], Vector2.ZERO)
		for point in polygon.polygon:
			bounds = bounds.expand(point)
		bounds.position += polygon.position
		var min_x := bounds.position.x - polygon.position.x
		var max_x := bounds.end.x - polygon.position.x
		for index in polygon.polygon.size():
			var start: Vector2 = polygon.polygon[index]
			var finish: Vector2 = polygon.polygon[(index + 1) % polygon.polygon.size()]
			if is_equal_approx(start.x, min_x) and is_equal_approx(finish.x, min_x):
				side_ranges[0] = Vector2(minf(start.y, finish.y), maxf(start.y, finish.y)) + Vector2(polygon.position.y, polygon.position.y)
			if is_equal_approx(start.x, max_x) and is_equal_approx(finish.x, max_x):
				side_ranges[1] = Vector2(minf(start.y, finish.y), maxf(start.y, finish.y)) + Vector2(polygon.position.y, polygon.position.y)
		for index in 2:
			if is_zero_approx(side_ranges[index].y - side_ranges[index].x):
				side_ranges[index] = Vector2(bounds.position.y, bounds.end.y)
	else:
		push_error("HazardPlatform requires a RectangleShape2D or CollisionPolygon2D.")
		return
	for side_index in 2:
		var direction := -1.0 if side_index == 0 else 1.0
		var side_top: float = side_ranges[side_index].x
		var side_bottom: float = side_ranges[side_index].y
		var side := Area2D.new()
		side.set_script(CONTACT_HAZARD)
		side.name = "LeftHazard" if direction < 0 else "RightHazard"
		side.damage = side_damage
		side.damage_interval = damage_interval
		side.knockback = side_knockback
		var shape := RectangleShape2D.new()
		# Inset below the top so landing and riding are safe.
		shape.size = Vector2(6, maxf(side_bottom - side_top - 8, 1))
		var collision := CollisionShape2D.new()
		collision.shape = shape
		var side_x := bounds.position.x if side_index == 0 else bounds.end.x
		side.position = Vector2(side_x + direction, (side_top + side_bottom) / 2.0)
		side.add_child(collision)
		add_child(side)
