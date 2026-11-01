extends Label
# Shows collected / total collectibles

func _ready() -> void:
	LevelManager.collectibles_changed.connect(_update)
	_update(LevelManager.collected, LevelManager.total_collectibles)

func _update(collected: int, total: int) -> void:
	text = "x%d" % [collected]
