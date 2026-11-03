extends EnemyController
@export var burst_duration := 3.0
@export var burst_rest := 2.0
@export var shot_interval := 0.75
var shot_clock := 0.0
@onready var weapon: Weapon = enemy.get_node_or_null("Weapon")
func tick(delta: float, _player: PlayerEntity, direction: float) -> void:
	shot_clock -= delta
	if fmod(enemy.attack_clock, burst_duration + burst_rest) < burst_duration and shot_clock <= 0 and weapon:
		weapon.fire(direction)
		shot_clock = shot_interval
