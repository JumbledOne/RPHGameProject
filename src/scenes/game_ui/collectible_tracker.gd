extends Label
# Shows collected / total collectibles

func _ready() -> void:
	LevelManager.collectibles_changed.connect(_update)
	LevelManager.cacao_changed.connect(_on_cacao_changed)
	_update(LevelManager.collected, LevelManager.total_collectibles)

func _update(collected: int, total: int) -> void:
	text = "%s / %s" % [collected, total]
	var bonus := LevelManager.cacao - collected
	if bonus > 0:
		text += " (+%d bonus)" % bonus

func _on_cacao_changed(_cacao: int) -> void:
	_update(LevelManager.collected, LevelManager.total_collectibles)
