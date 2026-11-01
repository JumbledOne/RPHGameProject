extends CanvasLayer

var is_victory: bool = false

func _ready() -> void:
	get_tree().paused = true

	if is_victory:
		%TitleLabel.text = "Larga na, Davao!"
		%SubLabel.text = "Level complete!"
		%StatsLabel.text = "Stars: %d / 3\nCacao: %d\nScore: %d" % [
			LevelManager.get_stars(), LevelManager.cacao, LevelManager.score]
		%RetryButton.hide()
	else:
		%TitleLabel.text = "Maayo ang pagsulay"
		%SubLabel.text = "Don't give up."
		%StatsLabel.hide()

	%RetryButton.pressed.connect(LevelManager.restart_level)
	%MenuButton.pressed.connect(LevelManager.return_to_main_menu)
	%RetryButton.pressed.connect(_play_menu_select)
	%MenuButton.pressed.connect(_play_menu_select)

func _play_menu_select() -> void:
	$MenuSelectAudio.play()
