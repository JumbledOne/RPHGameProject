extends Node

signal mute_changed(is_muted: bool)

@onready var music: AudioStreamPlayer = $AudioStreamPlayer
@onready var music_volume: float = music.volume_linear

var music_muted: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	LevelManager.game_started_event.connect(_on_game_started)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("mute") and not event.is_echo():
		toggle_mute()
		get_viewport().set_input_as_handled()

func toggle_mute() -> void:
	music_muted = not music_muted
	music.volume_linear = 0.0 if music_muted else music_volume
	mute_changed.emit(music_muted)

func _on_game_started() -> void:
	music.play()

func reset_music() -> void:
	music.stop()
	music.play()
