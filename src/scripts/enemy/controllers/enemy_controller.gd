class_name EnemyController
extends Node2D
@onready var enemy: Enemy_Entity = get_parent() as Enemy_Entity
func activated() -> void:
	pass
func deactivated() -> void:
	pass
func tick(_delta: float, _player: PlayerEntity, _direction: float) -> void:
	pass
