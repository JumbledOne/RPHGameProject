extends Label

func _ready() -> void:
	LevelManager.lives_changed.connect(_update)
	_update(LevelManager.lives_left)

func _update(lives: int) -> void:
	text = "x%d" % lives
