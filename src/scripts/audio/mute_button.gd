extends Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pressed.connect(Audio.toggle_mute)
	Audio.mute_changed.connect(_update_label)
	_update_label(Audio.music_muted)

func _update_label(is_muted: bool) -> void:
	text = "Unmute Music" if is_muted else "Mute Music"
