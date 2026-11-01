extends CanvasLayer

func _ready() -> void:
	$VBoxContainer/DamageButton.pressed.connect(func(): GameManager.damage(1))
	$VBoxContainer/HealButton.pressed.connect(func(): GameManager.heal(1))
	$VBoxContainer/CacaoButton.pressed.connect(func(): GameManager.add_cacao(1))
	$VBoxContainer/WinButton.pressed.connect(func(): GameManager.game_end(GameManager.GameEnd.WON))
