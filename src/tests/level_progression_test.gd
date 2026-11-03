extends Node
## Check authored pickup totals and the completed plantation/city encounters.

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	var game = load("res://scenes/game_scene/game_scene.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	for _frame in range(3):
		await get_tree().physics_frame
	for stage in range(5):
		LevelManager.start_game(stage)
		for _frame in range(4):
			await get_tree().physics_frame
		var level = game.get_node("LevelRoot").get_child(0)
		var items: TileMapLayer = level.get_node("LevelObjects/Items")
		var cacao := 0
		var durian := 0
		var goal_x: float = level.get_node("LevelObjects/LevelEnd").position.x
		for cell in items.get_used_cells():
			match items.get_cell_alternative_tile(cell):
				1: cacao += 1
				2: durian += 1
			check(items.map_to_local(cell).x < goal_x - 32.0, "Every pickup precedes the exit")
		check(cacao == (50 if stage == 0 else 40), "Level %d must author exactly 40 cacao" % (stage + 1))
		check(durian == 3, "Level %d must author exactly 3 durian" % (stage + 1))
		check(LevelManager.total_collectibles == (50 if stage == 0 else 40), "Level %d must instantiate 40 cacao" % (stage + 1))
		var actual_durian := 0
		for child in items.get_children():
			if child.get_script() == load("res://scripts/pickup/durian_pickup.gd"):
				actual_durian += 1
		check(actual_durian == 3, "Level %d must instantiate 3 durian" % (stage + 1))
		var trees = level.get_node_or_null("BackgroundEffects/BackPixelLayer/RouteVegetation")
		if stage == 2:
			check(level.get_node("RollingCart").position.is_equal_approx(Vector2(816, -16)), "Original first cart stays in place")
			check(level.get_node("LevelObjects/FallingCrate").position.is_equal_approx(Vector2(368, -240)), "Original first crate stays in place")
			check(trees == null, "Plantation deliberately has no greenery")
			check(level.find_children("*Colonizer*", "", true, false).is_empty(), "Plantation has no soldier")
			check(level.find_children("*Cart*", "", true, false).size() == 6, "Plantation extends the original three carts")
			check(level.find_children("*Crate*", "", true, false).size() == 7, "Plantation extends the original three drops")
		else:
			check(trees != null and trees.multi_mesh.multimesh.instance_count > 0, "Level %d generates vegetation" % (stage + 1))
		if stage == 4:
			check(level.get_node("LevelObjects/Jeepney").position.is_equal_approx(Vector2(1008, -40)), "Original first vehicle stays in place")
			var vehicles = level.find_children("*Jeepney*", "", true, false)
			check(vehicles.size() == 5, "City retains four original vehicles and adds one")
			for vehicle in vehicles:
				check(vehicle.has_node("LeftHazard") and vehicle.has_node("RightHazard"), "Vehicle sides initialize")
			check(level.get_node("LevelObjects/LevelEnd").position.x > 4000, "City exit follows the final encounters")
		print("LEVEL %d: cacao=%d durian=%d registered=%d" % [stage + 1, cacao, actual_durian, LevelManager.total_collectibles])
		if "--capture" in OS.get_cmdline_user_args() and stage in [2, 4]:
			var camera: Camera2D = level.get_node("PlayerCamera")
			camera.set_script(null)
			camera.position = Vector2(2080, -80)
			camera.zoom = Vector2(0.145, 0.65)
			camera.position_smoothing_enabled = false
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://../output/completed_level_%d.png" % (stage + 1))
			camera.position = Vector2(1760, -128)
			camera.zoom = Vector2.ONE
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://../output/completed_level_%d_detail.png" % (stage + 1))
		LevelManager.return_to_main_menu()
		for _frame in range(3):
			await get_tree().physics_frame
	for amount in [0, 3, 4, 7, 8, 11, 12, 15, 16, 39, 40]:
		LevelManager.collected = amount
		check(LevelManager.get_stars() == maxi(amount / 4 - 1, 0), "Stars follow the cacao formula for %d collected" % amount)
	var star_row = game.get_node("UIRoot/GameUi/EndScreen/VBoxContainer/StarContainer")
	check(star_row.get_child_count() == 9, "Result screen displays all nine possible stars")
	if "--capture" in OS.get_cmdline_user_args():
		InterfaceManager.open_ui("GameUi")
		game.get_node("UIRoot/GameUi")._end(LevelManager.GameEnd.WON)
		await get_tree().create_timer(5.5).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://../output/cacao_star_award.png")
	game.queue_free()
	await get_tree().process_frame
	print("Level progression checks: %d failures" % failures)
	get_tree().quit(failures)
