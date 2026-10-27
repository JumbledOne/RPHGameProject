extends CanvasLayer

var is_victory: bool = false

func _ready() -> void:
	get_tree().paused = true

	if is_victory:
		%TitleLabel.text = "Larga na, Davao!"
		%SubLabel.text = "Level complete!"
		%StatsLabel.text = "Stars: %d / 3\nCacao: %d\nScore: %d" % [
			GameState.get_stars(), GameState.cacao, GameState.score]
		%RetryButton.hide()
	else:
		%TitleLabel.text = "Maayo ang pagsulay"
		%SubLabel.text = "Don't give up."
		%StatsLabel.hide()

	%RetryButton.pressed.connect(GameState.restart_level)
	%MenuButton.pressed.connect(GameState.go_to_menu)
