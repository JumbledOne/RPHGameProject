class_name IdleComponent
extends Component

func tick(enemy: Enemy_Entity, delta: float):
	if not enemy.is_on_floor():
		enemy.velocity.y += 980.0 * delta
	else:
		enemy.velocity.y = 0.0
	
	faceTargetPos(enemy, GameManager.player.global_position.x)
