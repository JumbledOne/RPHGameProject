extends Node2D

@onready var particles: CPUParticles2D = $Particles

func _ready() -> void:
	particles.finished.connect(queue_free)
	particles.restart()
	particles.emitting = true
