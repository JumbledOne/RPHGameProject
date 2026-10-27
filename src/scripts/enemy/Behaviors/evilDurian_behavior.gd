class_name EvilDurianBehavior
extends Enemy_Behavior

func _ready() -> void:
	setAttackComponent(attackComponents.IDLE)
	setMovementComponent(movementComponents.CHASE)

func GameLogic(enemy: Enemy_Entity, delta: float):
	pass
