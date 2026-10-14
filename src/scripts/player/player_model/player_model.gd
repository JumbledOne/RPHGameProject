extends Node2D

@onready var player: PlatformerEntity = $".."

@onready var run_particles: CPUParticles2D = $RunParticles

func _ready() -> void:
	pass
	#player.sprint_changed.connect(_on_sprint_changed)
	
func _process(delta: float) -> void:
	run_particles.emitting = player.get_is_sprinting() and player.is_on_floor()
