extends EnemyController
@export var move_speed := 65.0
func tick(_delta: float, player: PlayerEntity, direction: float) -> void:
	enemy.velocity.x = direction * move_speed if absf(enemy.to_local(player.global_position).x) < 300 else 0.0
	if player.global_position.distance_to(enemy.global_position) < 45:
		player.hurt(1)
		player.velocity += Vector2(direction * 210, -110)
