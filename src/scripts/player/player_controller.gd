extends Node

@onready var player: PlatformerEntity = $".."

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		player.begin_jump()
	elif event.is_action_released("jump"):
		player.release_jump()
	elif event.is_action_pressed("sprint"):
		player.begin_sprint()
	elif event.is_action_released("sprint"):
		player.release_sprint()

func _physics_process(delta: float) -> void:
	player.horizontal_movement = Input.get_axis("left", "right")
