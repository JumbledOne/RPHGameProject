extends Node2D

@onready var entity: PlatformerEntity = get_parent().get_parent()
@onready var particles: CPUParticles2D = $Particles

func _ready() -> void:
	particles.one_shot = true
	particles.emitting = false
	entity.landed.connect(_on_landed)

func _on_landed() -> void:
	particles.restart()
	particles.emitting = true
