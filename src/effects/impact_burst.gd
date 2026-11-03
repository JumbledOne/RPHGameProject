extends Node2D
## Pixel burst is generated from small squares, with no missing sprite dependency.
var age := 0.0
func _process(delta: float) -> void:
	age += delta
	if age > 0.28:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var progress := age / 0.28
	var color := Color(1.0, 0.72 - progress * 0.35, 0.25, 1.0 - progress)
	for i in range(8):
		var offset := Vector2.from_angle(i * TAU / 8) * (5 + progress * 34)
		draw_rect(Rect2(offset.round() - Vector2(4, 4), Vector2(8, 8)), color)
	draw_rect(Rect2(-6, -6, 12, 12), Color(1, 0.95, 0.65, 1 - progress))
