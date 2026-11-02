class_name HazardPlatform
extends MovingPlatform
## The top and underside are solid; only the two side strips deal damage.

const CONTACT_HAZARD = preload("res://scripts/level_objects/static_hazard.gd")

@export_range(0, 10) var side_damage: int = 1
@export_range(0.1, 5.0) var damage_interval: float = 1.0
@export var side_knockback: Vector2 = Vector2(180, -80)

func _ready() -> void:
	super()
	var collider := $CollisionShape2D as CollisionShape2D
	var rectangle := collider.shape as RectangleShape2D
	if rectangle == null:
		push_error("HazardPlatform requires a RectangleShape2D collision shape.")
		return
	for direction in [-1.0, 1.0]:
		var side := Area2D.new()
		side.set_script(CONTACT_HAZARD)
		side.name = "LeftHazard" if direction < 0 else "RightHazard"
		side.damage = side_damage
		side.damage_interval = damage_interval
		side.knockback = side_knockback
		var shape := RectangleShape2D.new()
		# Inset below the top so landing and riding are safe.
		shape.size = Vector2(6, maxf(rectangle.size.y - 8, 1))
		var collision := CollisionShape2D.new()
		collision.shape = shape
		side.position = collider.position + Vector2(direction * (rectangle.size.x / 2.0 + 1), 2)
		side.add_child(collision)
		add_child(side)
