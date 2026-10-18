class_name IdleComponent
extends Component


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func tick(enemy: Enemy_Entity, delta: float):
	if not enemy.is_on_floor():
		enemy.velocity.y += 980.0 * delta
	else:
		enemy.velocity.y = 0.0
