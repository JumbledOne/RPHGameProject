extends Enemy_Entity

@export var projectile_scene: PackedScene
@export var activation_windup: float = 0.9
@export var shot_interval: float = 2.0

var shot_clock := 0.0

func _on_activated() -> void:
	shot_clock = activation_windup

func _update_enemy(delta: float, _player: PlayerEntity, direction: float) -> void:
	shot_clock -= delta
	if shot_clock <= 0.0 and projectile_scene != null:
		level.fire_projectile(projectile_scene, global_position + Vector2(direction * 24.0, -8.0), direction)
		shot_clock = shot_interval
