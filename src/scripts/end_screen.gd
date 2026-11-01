extends CanvasLayer

var is_victory: bool = false

func _ready() -> void:
	get_tree().paused = true

	if is_victory:
		%TitleLabel.text = "Larga na, Davao!"
		%SubLabel.text = "Level complete!"
		%StatsLabel.text = "Stars: %d / 3\nCacao: %d\nScore: %d" % [
			GameManager.get_stars(), GameManager.cacao, GameManager.score]
		%RetryButton.hide()
	else:
		%TitleLabel.text = "Maayo ang pagsulay"
		%SubLabel.text = "Don't give up."
		%StatsLabel.hide()

	%RetryButton.pressed.connect(GameManager.restart_level)
	%MenuButton.pressed.connect(GameManager.go_to_menu)
	%RetryButton.pressed.connect(_play_menu_select)
	%MenuButton.pressed.connect(_play_menu_select)

func _play_menu_select() -> void:
	$MenuSelectAudio.play()
