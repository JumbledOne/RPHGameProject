@abstract class_name EnemyBehavior
extends Node

@export var speed: float = 200.0

@abstract func tick(enemy: CharacterBody2D, delta: float) -> void
