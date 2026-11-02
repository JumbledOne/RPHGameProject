@tool
extends Control
## Fits the horizontal extent of this Control to a TileMapLayer's used cells.
## Keeps the authored vertical position and height. Works in the editor and game.
@export var tilemap: TileMapLayer
@export var extend_to_tilemap: bool = true
@export var left_margin: float = 0.0
@export var right_margin: float = 0.0

func _ready() -> void:
	update_extent()

func _process(_delta: float) -> void:
	update_extent()

func update_extent() -> void:
	if not extend_to_tilemap:
		return
	if not is_instance_valid(tilemap):
		var ancestor := get_parent()
		while ancestor != null:
			tilemap = ancestor.get_node_or_null("TileMapLayer") as TileMapLayer
			if tilemap != null:
				break
			ancestor = ancestor.get_parent()
	if tilemap == null or tilemap.tile_set == null:
		return
	var cells := tilemap.get_used_rect()
	if cells.size.x == 0:
		return
	var half_tile := Vector2(tilemap.tile_set.tile_size) * 0.5
	var start := tilemap.to_global(tilemap.map_to_local(cells.position) - half_tile)
	var end := tilemap.to_global(tilemap.map_to_local(cells.end - Vector2i.ONE) + half_tile)
	var canvas_parent := get_parent() as CanvasItem
	if canvas_parent != null:
		var parent_inverse := canvas_parent.get_global_transform().affine_inverse()
		start = parent_inverse * start
		end = parent_inverse * end
	var new_x := minf(start.x, end.x) - left_margin
	var new_width := (absf(end.x - start.x) + left_margin + right_margin) / maxf(absf(scale.x), 0.001)
	if not is_equal_approx(position.x, new_x):
		position.x = new_x
	if not is_equal_approx(size.x, new_width):
		size.x = new_width
