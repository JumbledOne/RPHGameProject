extends Label

@onready var game_manager: Node = get_node("/root/GameManager")

func _ready() -> void:
	game_manager.lives_changed.connect(_update)
	_update(game_manager.lives_left)

func _update(lives: int) -> void:
	text = "Lives: %d" % lives
