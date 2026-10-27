class_name BlindingColonizerBehavior
extends Enemy_Behavior

func _ready() -> void:
	setAttackComponent(attackComponents.BLIND)
	setMovementComponent(movementComponents.IDLE)

func GameLogic(enemy: Enemy_Entity, delta: float):
	pass
