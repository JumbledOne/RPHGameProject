extends AudioStreamPlayer2D

func _ready() -> void:
	pitch_scale = randf_range(0.9, 1.1)
	play()
