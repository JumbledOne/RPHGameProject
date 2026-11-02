extends Node2D

func _draw() -> void:
	draw_rect(Rect2(-4.0, -4.0, 8.0, 8.0), Color.WHITE)

func _ready() -> void:
	queue_redraw()
