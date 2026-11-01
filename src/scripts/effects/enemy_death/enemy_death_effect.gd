extends Node2D

@onready var particles: CPUParticles2D = $Particles
@onready var flash: Sprite2D = $Flash

@export var flash_start_scale: float = 0.03
@export var flash_end_scale: float = 0.14

func _ready() -> void:
	particles.one_shot = true
	particles.emitting = true
	particles.finished.connect(queue_free)

	flash.scale = Vector2.ONE * flash_start_scale
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "scale", Vector2.ONE * flash_end_scale, particles.lifetime)
	tween.tween_property(flash, "modulate:a", 0.0, particles.lifetime)
