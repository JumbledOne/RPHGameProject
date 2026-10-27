extends CanvasLayer

# Show only when the game isn't running
func _ready() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_ended.connect(_on_game_ended)
	hide()
	
func _on_game_started():
	show()
	
func _on_game_ended():
	hide()
