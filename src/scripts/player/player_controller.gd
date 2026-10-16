extends Node

@onready var player: PlatformerEntity = $".."
var attack_action = PlayerAttack.new()

func _input(event: InputEvent) -> void:
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
		player.do_action()
	if event.is_action("attack"):
		player.player_action = attack_action
		player.do_action()

func _physics_process(_delta: float) -> void:
	player.horizontal_movement = Input.get_axis("left", "right")
