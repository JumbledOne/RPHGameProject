extends Node

@export_category("Movement")
@export var walk_speed: float = 10
@export var sprint_speed: float = 20

@export_category("Jump")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint"):
		pass
	elif event.is_action_released("sprint"):
		pass
	elif event.is_action_pressed("ability"):
		pass

func _physics_process(delta: float) -> void:
	pass
