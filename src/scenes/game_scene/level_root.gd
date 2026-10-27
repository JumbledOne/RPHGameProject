extends Node2D

func _ready() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_ended.connect(_on_game_ended)
	
func _on_game_started():
	_clear_children()
	var scene: PackedScene = GameManager.LEVELS[GameManager.current_level]
	add_child(scene.instantiate())
	
func _on_game_ended():
	_clear_children()
	
func _clear_children():
	for e in get_children():
		e.queue_free()
