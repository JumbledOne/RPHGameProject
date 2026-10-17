extends Button
# Also feel free to delete this if not needed

func _pressed() -> void:
	if GameManager.player:
		GameManager.player.hurt()
