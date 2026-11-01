class_name TestEnemyBehavior
extends Enemy_Behavior

func _ready() -> void:
	setAttackComponent(attackComponents.IDLE)
	setMovementComponent(movementComponents.IDLE)

func GameLogic(enemy: Enemy_Entity, delta: float):
	pass
