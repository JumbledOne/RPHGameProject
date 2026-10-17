extends "res://scripts/health_display/health_display.gd"
# Testing only
# May remove if not needed

func _ready() -> void:
	GameManager.player_set.connect(_on_player_set)
	
func _on_player_set():
	link_entity(GameManager.player)
