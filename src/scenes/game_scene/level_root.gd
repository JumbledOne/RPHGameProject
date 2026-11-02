extends Node2D

func _ready() -> void:
	add_to_group("level_root")
	LevelManager.game_started_event.connect(_on_game_started)
	LevelManager.game_ended.connect(_on_game_ended)
	GameManager.pause_toggled.connect(_on_pause_toggled)
	if not LevelManager.preview_scene_path.is_empty():
		LevelManager.start_game.call_deferred(LevelManager.selected_level)

func _on_pause_toggled() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED if GameManager.is_paused else Node.PROCESS_MODE_INHERIT
	
func _on_game_started():
	process_mode = Node.PROCESS_MODE_INHERIT
	_clear_children()
	var scene: PackedScene = LevelManager.get_level_scene()
	add_child(scene.instantiate())
	
func _on_game_ended(result: int):
	if result == LevelManager.GameEnd.WON:
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		return
	_clear_children()
	
func _clear_children():
	# The old player is only queued for deletion, so drop the reference now or
	# the new level's PlayerSpawner thinks a player already exists.
	GameManager.player = null
	for e in get_children():
		remove_child(e)
		e.queue_free()

func clear_level() -> void:
	_clear_children()
