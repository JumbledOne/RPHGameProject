extends CampaignEnemy

@export var move_speed: float = 65.0

func _update_enemy(_delta: float, player: PlayerEntity, direction: float) -> void:
	velocity.x = direction * move_speed if absf(to_local(player.global_position).x) < 300.0 else 0.0
	if player.global_position.distance_to(global_position) < 45.0:
		player.hurt(1)
		player.velocity += Vector2(direction * 210.0, -110.0)
