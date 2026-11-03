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
	GameManager.player = null
	if get_tree().get_first_node_in_group("level_root") == null:
		await get_tree().create_timer(0.5).timeout
		if is_inside_tree():
			spawn()
