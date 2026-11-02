extends Node
var failures := 0
func _ready() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in range(count):
		await get_tree().physics_frame

func _run() -> void:
	var game = load("res://scenes/game_scene/game_scene.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	await frames(3)
	check(ResourceLoader.exists("res://scenes/levels/level_1_old.tscn"), "Old level one is preserved")
	for stage in range(5):
		LevelManager.start_game(stage)
		await frames(3)
		var root = game.get_node("LevelRoot")
		check(root.get_child_count() == 1, "One active level")
		var level = root.get_child(0)
		check(level.get_script() == load("res://scenes/base_level/base_level.gd"), "Level %d inherits BaseLevel behavior" % (stage + 1))
		check(level.scene_file_path == "res://scenes/levels/level_%d.tscn" % (stage + 1), "Correct level scene selected")
		check(level.get_node_or_null("LevelObjects/Items") != null, "Inherited item layer")
		check(level.get_node_or_null("PlayerCamera") is Camera2D, "Inherited camera")
		check(level.get_node_or_null("Player") == GameManager.player, "Single inherited player")
		var water_layer = level.get_node("WaterLayer")
		check(water_layer is CanvasGroup and water_layer.material == preload("res://assets/gfx/gfx_resources/material/water.tres"), "Inherited water CanvasGroup uses the required material")
		check(water_layer.get_node("Water").extend_to_tilemap, "Shared water extends with the tilemap")
		check(level.get_node_or_null("LevelObjects/Water") == null, "No water instance outside the CanvasGroup")
		check(level.get_node("BackgroundEffects/Fog").get_script() == preload("res://scripts/misc/level_extender.gd"), "Fog uses the extender")
		var simple_fog = level.get_node_or_null("BackgroundEffects/SimpleFog")
		check(simple_fog == null or simple_fog.get_script() == null, "SimpleFog has no extender")
		var ends = level.find_children("LevelEnd", "", true, false)
		check(ends.size() == 1, "Exactly one level end in level %d" % (stage + 1))
		var tile = level.get_node("TileMapLayer")
		check(tile.get_used_rect().size.x >= 80, "Floor spans each level")
		check(level.find_children("FeatureShowcase", "", true, false).is_empty(), "Mixed showcase removed")
		check(level.get_node_or_null("LevelObjects/RottenCacao") != null, "Copyable enemy instances present")
		check(level.get_node("Background/Sprite2D").texture.resource_path == LevelManager.get_level_info(stage).texture, "Correct era background")
		await frames(45)
		check(is_instance_valid(GameManager.player) and GameManager.player.is_on_floor(), "Player lands safely on the level floor")
		var ui = game.get_node("UIRoot/GameUi")
		check(ui.get_node_or_null("EndScreen") == ui.result and ui.result.owner == ui, "End screen is serialized directly in GameUi")
		check(ui.get_node_or_null("StatsBar/VBoxHealth/Hearts") != null, "Original health HUD restored")
		check(ui.get_node_or_null("StatsBar/VBoxTime/TimeLimitLabel") != null, "Original timer restored")
		check(ui.get_node_or_null("EscapeMenu/Screens") != null, "Original pause/settings UI restored")
		if "--capture" in OS.get_cmdline_user_args():
			await capture("level_elements_%d" % (stage + 1))
		GameManager.set_pause(true)
		check(ui.get_node("EscapeMenu").visible, "Original pause menu opens")
		ui.get_node("EscapeMenu")._on_resume_pressed()
		check(not GameManager.is_paused, "Original Resume works")
		ends[0]._go_next_level()
		await frames(3)
		check(ui.result.visible and ui.result_title.text == "Larga na, Davao!", "Kept victory end screen")
		if stage == 0 and "--capture" in OS.get_cmdline_user_args():
			await capture("kept_end_screen")
		LevelManager.return_to_main_menu()
		await frames(3)
		check(GameManager.player == null and not get_tree().paused, "Menu cleanup works")
	LevelManager.start_game(0)
	await frames(3)
	LevelManager.game_end(LevelManager.GameEnd.LOST)
	await frames(3)
	check(game.get_node("UIRoot/GameUi").result_title.text == "Maayo ang pagsulay", "Kept loss end screen")
	LevelManager.restart_level()
	await frames(3)
	check(is_instance_valid(GameManager.player) and not game.get_node("UIRoot/GameUi").result.visible, "Retry clears end screen")
	LevelManager.return_to_main_menu()
	await frames(3)
	game.queue_free()
	await frames(3)
	print("Level/UI setup tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	get_tree().quit(0 if failures == 0 else 1)

func capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../output/%s.png" % filename)
