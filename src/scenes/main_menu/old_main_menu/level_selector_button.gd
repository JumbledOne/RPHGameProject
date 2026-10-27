extends Button

var level: int = -1

func _ready() -> void:
	toggle_mode = true

func set_level_data(new_level: int, info_dict: Dictionary):
	level = new_level
	text = "Level %d - %s" % [level + 1, info_dict["title"]]
