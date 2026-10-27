extends Button

var _level: int = -1

func _pressed() -> void:
	GameManager.start_game(_level)

func _ready() -> void:
	toggle_mode = true

func set_level_data(level: int, info_dict: Dictionary):
	_level = level
	text = "Level %d - %s" % [level + 1, info_dict["title"]]
