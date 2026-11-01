extends Node

@onready var music: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	LevelManager.game_started_event.connect(_on_game_started)

func _on_game_started() -> void:
	music.play()
