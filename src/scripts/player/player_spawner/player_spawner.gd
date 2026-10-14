extends Node2D

const PLAYER = preload("uid://dyqbnaxeopk17")

func _ready() -> void:
	spawn()

func spawn():
	if GameManager.player:
		return
	var player: PlayerEntity = PLAYER.instantiate()
	player.global_position = global_position
	get_parent().add_child.call_deferred(player)
	GameManager.player = player
	player.died.connect(_on_player_died)

func _on_player_died():
	spawn()
