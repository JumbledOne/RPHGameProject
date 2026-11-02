extends CPUParticles2D

func _ready() -> void:
	one_shot = true
	finished.connect(queue_free)
