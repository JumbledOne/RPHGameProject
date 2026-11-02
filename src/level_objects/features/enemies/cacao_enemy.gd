extends Enemy_Entity

@export var poison_interval: float = 10.0

func _update_enemy(_delta: float, player: PlayerEntity, _direction: float) -> void:
	if attack_clock >= poison_interval:
		player.hurt(1)
		attack_clock = 0.0
