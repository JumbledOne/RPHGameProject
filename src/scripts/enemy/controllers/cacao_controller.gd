extends EnemyController
@export var poison_interval := 10.0
func tick(_delta: float, player: PlayerEntity, _direction: float) -> void:
	if enemy.attack_clock >= poison_interval:
		player.hurt(1)
		enemy.attack_clock = 0.0
