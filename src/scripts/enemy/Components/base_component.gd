@abstract class_name Component
extends Node2D

@abstract func tick(enemy: Enemy_Entity, delta: float) -> void

func faceTargetPos(enemy: Enemy_Entity, x: float) -> void:
	if enemy.global_position.x < x:
		flip_sprite.emit(false)
	else:
		flip_sprite.emit(true)

signal animation_request(animation_name: String)
signal flip_sprite(direction: bool)
