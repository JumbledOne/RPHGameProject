extends Node
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	var fixture := Node2D.new()
	fixture.position = Vector2(100, 30)
	add_child(fixture)
	var tile := TileMapLayer.new()
	tile.name = "TileMapLayer"
	tile.tile_set = preload("res://assets/gfx/gfx_resources/level_tile_set.tres")
	tile.position.x = -64
	tile.set_cell(Vector2i(-3, 0), 0, Vector2i(1, 0))
	tile.set_cell(Vector2i(9, 0), 0, Vector2i(1, 0))
	fixture.add_child(tile)
	var fog := ColorRect.new()
	fog.set_script(preload("res://scripts/misc/level_extender.gd"))
	fog.position = Vector2(999, -80)
	fog.size = Vector2(4, 200)
	fixture.add_child(fog)
	check(is_equal_approx(fog.position.x, -160) and is_equal_approx(fog.size.x, 416), "Extends over negative cells and translated tilemap")
	check(fog.position.y == -80 and fog.size.y == 200, "Preserves authored vertical extent")
	tile.set_cell(Vector2i(12, 0), 0, Vector2i(1, 0))
	fog.update_extent()
	check(fog.size.x == 512, "Updates when terrain grows")
	fog.left_margin = 12
	fog.right_margin = 24
	fog.update_extent()
	check(fog.position.x == -172 and fog.size.x == 548, "Supports margins")
	var water = preload("res://level_objects/water/water.tscn").instantiate()
	water.extend_to_tilemap = true
	fixture.add_child(water)
	await get_tree().process_frame
	check(water.size.x == 512, "Water uses the shared extender")
	check(water.get_node("Area2D/CollisionShape2D").shape.size.x == 512, "Water collision follows its extended width")
	var pool = preload("res://level_objects/water/water.tscn").instantiate()
	fixture.add_child(pool)
	check(pool.size.x == 500, "Local pools keep their authored width")
	fixture.queue_free()
	await get_tree().process_frame
	print("Level extender tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	get_tree().quit(failures)
