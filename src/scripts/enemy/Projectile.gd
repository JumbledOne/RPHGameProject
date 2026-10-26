class_name Projectile
extends Area2D

@export var speed: float = 600.0
var direction: float = 1.0  # 1.0 for right, -1.0 for left

func _physics_process(delta: float) -> void:
	global_position.x += direction * speed * delta

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
