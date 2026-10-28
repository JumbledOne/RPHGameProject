extends Panel

const WATER_STYLE: StyleBox = preload("res://assets/gfx/gfx_resources/stylebox/water_gradient.tres")
const WATER_SPLASH: PackedScene = preload("res://scripts/effects/water_splash/water_splash.tscn")
const TOP_MARGIN: float = 16.0

@onready var water_area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	add_theme_stylebox_override("panel", WATER_STYLE)
	collision_shape.shape = collision_shape.shape.duplicate()
	_update_collision_shape()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_update_collision_shape()

func _update_collision_shape() -> void:
	var collider_height: float = maxf(size.y - TOP_MARGIN, 0.0)
	water_area.position = Vector2(size.x * 0.5, TOP_MARGIN + collider_height * 0.5)
	(collision_shape.shape as RectangleShape2D).size = Vector2(size.x, collider_height)

func _on_body_entered(body: Node2D) -> void:
	var submersible: Submersible = body.get_node_or_null("Submersible")
	if submersible:
		submersible.enter_water()
	if body is RigidBody2D or body is CharacterBody2D:
		_entered_water(body.global_position, body.get("velocity"))

func _on_body_exited(body: Node2D) -> void:
	var submersible: Submersible = body.get_node_or_null("Submersible")
	if submersible:
		submersible.exit_water()

func _entered_water(pos: Vector2, velocity: Vector2) -> void:
	var splash: Node2D = WATER_SPLASH.instantiate()
	add_child(splash)
	splash.global_position = pos
