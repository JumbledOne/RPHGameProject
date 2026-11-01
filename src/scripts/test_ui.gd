extends CanvasLayer

func _ready() -> void:
	$VBoxContainer/DamageButton.pressed.connect(func():
		if is_instance_valid(GameManager.player):
			GameManager.player.hurt(1)
	)
	$VBoxContainer/HealButton.pressed.connect(func():
		if is_instance_valid(GameManager.player):
			GameManager.player.heal(1)
	)
	$VBoxContainer/CacaoButton.pressed.connect(func(): LevelManager.add_cacao(1))
	$VBoxContainer/WinButton.pressed.connect(func(): LevelManager.game_end(LevelManager.GameEnd.WON))
