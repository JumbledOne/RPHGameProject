extends Node2D

var tween: Tween

func _ready() -> void:
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * 2, 1.0)
	tween.parallel().tween_property(self, "modulate:a", 0, 1.0)
	tween.finished.connect(queue_free)
