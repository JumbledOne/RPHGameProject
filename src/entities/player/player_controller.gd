extends Node

@onready var player: PlayerEntity = $".."

func _input(event: InputEvent) -> void:
	if GameManager.is_paused or not LevelManager.game_started or player.is_queued_for_deletion():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_Q:
		player.eat_durian()
	# Movement
	if event.is_action_pressed("jump"):
		player.begin_jump()
	elif event.is_action_released("jump"):
		player.release_jump()
	elif event.is_action_pressed("sprint"):
		player.begin_sprint()
	elif event.is_action_released("sprint"):
		player.release_sprint()
	# Action
	if event.is_action_pressed("ability"):
		player.do_ability()
	if event.is_action_pressed("attack"):
		player.do_attack()

func _physics_process(_delta: float) -> void:
	player.horizontal_movement = 0.0 if GameManager.is_paused else Input.get_axis("left", "right")
