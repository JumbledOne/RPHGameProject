extends EnemyController
@export var activation_windup := 0.9
@export var shot_interval := 2.0
var shot_clock := 0.0
@onready var weapon: Weapon = enemy.get_node_or_null("Weapon")
func activated() -> void:
	shot_clock = activation_windup
func tick(delta: float, _player: PlayerEntity, direction: float) -> void:
	shot_clock -= delta
	if shot_clock <= 0 and weapon:
		weapon.fire(direction)
		shot_clock = shot_interval
