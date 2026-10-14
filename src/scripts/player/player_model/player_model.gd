extends Node2D

@onready var player: PlatformerEntity = $".."

@onready var run_particles: CPUParticles2D = $RunParticles

func _ready() -> void:
	player.jumped.connect(_on_jumped)
	
func _process(_delta: float) -> void:
	var on_floor: bool = player.is_on_floor()
	run_particles.emitting = player.get_is_sprinting() and on_floor

func _on_jumped():
	pass
