extends Node2D

const LIFETIME: float = 0.45
const CLOUD_COLOR := Color(0.88, 0.92, 1.0, 0.9)

func _ready() -> void:
	scale = Vector2(0.65, 0.65)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), LIFETIME)
	tween.tween_property(self, "modulate:a", 0.0, LIFETIME)
	await tween.finished
	queue_free()

func _draw() -> void:
	draw_circle(Vector2(-8, 2), 7.0, CLOUD_COLOR)
	draw_circle(Vector2(-3, -3), 9.0, CLOUD_COLOR)
	draw_circle(Vector2(5, -4), 8.0, CLOUD_COLOR)
	draw_circle(Vector2(10, 1), 6.0, CLOUD_COLOR)
	draw_rect(Rect2(-9, -1, 18, 8), CLOUD_COLOR)
