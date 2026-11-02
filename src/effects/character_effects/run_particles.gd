extends Node2D

@onready var entity: PlatformerEntity = get_parent().get_parent()
@onready var particles: CPUParticles2D = $Particles

func _ready() -> void:
	entity.sprint_changed.connect(_on_sprint_changed)
	_update_emission()

func _process(_delta: float) -> void:
	_update_emission()

func _on_sprint_changed() -> void:
	_update_emission()

func _update_emission() -> void:
	particles.emitting = entity.get_is_sprinting() and entity.is_on_floor() and not is_zero_approx(entity.horizontal_movement)
