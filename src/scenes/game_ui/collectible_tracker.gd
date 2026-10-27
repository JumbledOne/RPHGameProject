extends Label
# Shows collected / total collectibles

func _ready() -> void:
	GameManager.collectibles_changed.connect(_update)
	_update(GameManager.collected, GameManager.total_collectibles)

func _update(collected: int, total: int) -> void:
	text = "%d / %d" % [collected, total]
