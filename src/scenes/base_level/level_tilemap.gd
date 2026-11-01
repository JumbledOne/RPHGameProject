extends TileMapLayer

func _ready() -> void:
	var rect: Rect2i = get_used_rect()
	var tile_x = tile_set.tile_size.x
	LevelManager.level_left_boundary = (rect.position.x + 1.0) * tile_x
	LevelManager.level_right_boundary = (rect.position.x + rect.size.x - 1.0) * tile_x
