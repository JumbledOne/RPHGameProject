extends Node2D

func begin_end_level_sequence():
	var player: PlatformerEntity = GameManager.player
	var controller = player.get_node_or_null("PlayerController")
	if controller:
		controller.queue_free()
	player.horizontal_movement = 1
	GameManager.player = null
	$"Bar".queue_free()
	$Area2D.queue_free()
