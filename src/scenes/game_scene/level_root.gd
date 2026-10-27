extends Node2D

func _ready() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_ended.connect(_on_game_ended)
	
func _on_game_started():
	_clear_children()
	var scene: PackedScene = GameManager.get_level_scene()
	add_child(scene.instantiate())
	
func _on_game_ended():
	_clear_children()
	
func _clear_children():
	# The old player is only queued for deletion, so drop the reference now or
	# the new level's PlayerSpawner thinks a player already exists.
	GameManager.player = null
	for e in get_children():
		e.queue_free()
