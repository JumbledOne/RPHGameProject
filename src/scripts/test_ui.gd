extends CanvasLayer

func _ready() -> void:
	$VBoxContainer/DamageButton.pressed.connect(func(): GameState.damage(1))
	$VBoxContainer/HealButton.pressed.connect(func(): GameState.heal(1))
	$VBoxContainer/CacaoButton.pressed.connect(func(): GameState.add_cacao(1))
	$VBoxContainer/WinButton.pressed.connect(func(): GameState.level_won.emit())
