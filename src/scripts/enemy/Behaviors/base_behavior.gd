@abstract class_name Enemy_Behavior
extends Node2D

# so its easy to access the components

enum attackComponents {
	IDLE,
	GUARANTEED_HIT
}

const attackComponentScripts = {
	attackComponents.IDLE: preload("res://scripts/enemy/Components/AttackComponents/none.gd"),
	attackComponents.GUARANTEED_HIT: preload("res://scripts/enemy/Components/AttackComponents/Guaranteed_Hit.gd")
}


enum movementComponents {
	IDLE,
	CHASE
}

const movementComponentScripts = {
	movementComponents.IDLE: preload("res://scripts/enemy/Components/MovementComponents/Idle.gd"),
	movementComponents.CHASE: preload("res://scripts/enemy/Components/MovementComponents/Chase.gd")
}

# should be called inside func _process()
@onready var attack_Component = $AttackComponent

# should be called inside func _physics_process()
@onready var movement_Component = $MovementComponent

# so behaviorManager can read the game
@abstract func GameLogic(enemy: Enemy_Entity, delta: float)


func process_tick(enemy: Enemy_Entity, delta: float) -> void:
	GameLogic(enemy, delta)
	
	if attack_Component.has_method("tick"):
		attack_Component.tick(enemy, delta)

func physics_process_tick(enemy: Enemy_Entity, delta: float) -> void:
	GameLogic(enemy, delta)
	
	if movement_Component.has_method("tick"):
		movement_Component.tick(enemy, delta)

# setters
func setMovementComponent(new_component: movementComponents) -> void:
	if new_component in movementComponentScripts:
		movement_Component.set_script(movementComponentScripts[new_component])

func setAttackComponent(new_component: attackComponents) -> void:
	if new_component in attackComponentScripts:
		attack_Component.set_script(attackComponentScripts[new_component])
