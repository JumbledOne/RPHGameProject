extends TileMapLayer

func _ready() -> void:
	var rect: Rect2i = get_used_rect()
	var tile_x = tile_set.tile_size.x
	GameManager.level_left_boundary = (rect.position.x + 1.0) * tile_x
	GameManager.level_right_boundary = (rect.position.x + rect.size.x - 1.0) * tile_x
