class_name RottenCacaoBehavior
extends Enemy_Behavior

func _ready() -> void:
	setAttackComponent(attackComponents.GUARANTEED_HIT)
	setMovementComponent(movementComponents.IDLE)

func GameLogic(enemy: Enemy_Entity, delta: float):
	pass
