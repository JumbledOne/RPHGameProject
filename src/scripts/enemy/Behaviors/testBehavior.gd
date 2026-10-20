class_name TestEnemyBehavior
extends Enemy_Behavior

func _ready() -> void:
	setAttackComponent(attackComponents.GUARANTEED_HIT)
	setMovementComponent(movementComponents.CHASE)

func GameLogic(enemy: Enemy_Entity, delta: float):
	pass
