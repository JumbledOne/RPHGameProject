extends Label
# Shows collected / total collectibles

@onready var game_manager: Node = get_node("/root/GameManager")

func _ready() -> void:
	game_manager.collectibles_changed.connect(_update)
	_update(game_manager.collected, game_manager.total_collectibles)

func _update(collected: int, total: int) -> void:
	text = "%d / %d" % [collected, total]
