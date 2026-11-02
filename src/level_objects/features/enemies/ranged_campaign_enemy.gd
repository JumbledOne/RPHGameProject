extends Enemy_Entity

@export var projectile_scene: PackedScene
@export var burst_duration: float = 3.0
@export var burst_rest: float = 2.0
@export var shot_interval: float = 0.75

var shot_clock := 0.0

func _update_enemy(delta: float, _player: PlayerEntity, direction: float) -> void:
	shot_clock -= delta
	if fmod(attack_clock, burst_duration + burst_rest) < burst_duration and shot_clock <= 0.0 and projectile_scene != null:
		level.fire_projectile(projectile_scene, global_position + Vector2(direction * 24.0, -8.0), direction)
		shot_clock = shot_interval
