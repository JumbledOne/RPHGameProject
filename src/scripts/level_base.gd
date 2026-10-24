extends Node2D
# Attach this script to the root node of EVERY level scene

const HUD_SCENE = preload("res://scenes/ui/hud.tscn")
const END_SCREEN = preload("res://scenes/ui/end_screen.tscn")

func _ready() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.show_timeline_title()
	GameState.player_died.connect(_on_died, CONNECT_ONE_SHOT)
	GameState.level_won.connect(_on_won, CONNECT_ONE_SHOT)

func _on_died() -> void:
	_show_end(false)

func _on_won() -> void:
	_show_end(true)

func _show_end(win: bool) -> void:
	var screen = END_SCREEN.instantiate()
	screen.is_victory = win
	add_child(screen)
