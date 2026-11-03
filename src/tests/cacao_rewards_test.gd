extends SceneTree

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var manager := root.get_node("LevelManager")
	for total in [1, 8, 15, 40, 50]:
		manager._reset_level_stats()
		manager.total_collectibles = total
		for index in range(total):
			manager.collect()
		check(manager.get_stars() == 3, "Every pickup earns three stars for total %d without a boss" % total)
		manager.add_bonus_cacao(20)
		check(manager.get_stars() == 3 and manager.collected == total, "Bonus preserves complete pickup rating")
		check(manager.cacao == total + 20, "Bonus adds to cacao currency")
		check(manager.score > 0, "Cacao rewards contribute to score")
	manager._reset_level_stats()
	check(manager.get_stars() == 0, "An empty level does not award three stars")
	manager.total_collectibles = 40
	for index in range(39):
		manager.collect()
	manager.add_bonus_cacao(20)
	check(manager.get_stars() == 2, "Bonus cannot replace a missed level pickup")
	manager.collect()
	check(manager.cacao == 60 and manager.get_stars() == 3, "Picking up cacao after a bonus preserves currency")
	var tracker := Label.new()
	tracker.set_script(load("res://scenes/game_ui/collectible_tracker.gd"))
	root.add_child(tracker)
	check(tracker.text == "40 / 40 (+20 bonus)", "HUD displays bonus alongside the level pickup count")
	tracker.free()

	var fixture := Node2D.new()
	root.add_child(fixture)
	current_scene = fixture
	for hit in [true, false]:
		manager._reset_level_stats()
		var goal = load("res://level_objects/level_end/level_end.tscn").instantiate()
		fixture.add_child(goal)
		goal.get_node("Bar/AnimationPlayer").pause()
		for sample in [[-40.0, 0], [-94.0, 5], [-148.0, 10], [-202.0, 15], [-256.0, 20], [0.0, 0], [-300.0, 20]]:
			goal.get_node("Bar").position.y = sample[0]
			check(goal.get_cacao_reward() == sample[1], "Bar height %s awards %s cacao" % sample)
		goal.get_node("Bar").position.y = -148.0
		var player = load("res://entities/player/player.tscn").instantiate()
		fixture.add_child(player)
		goal.begin_end_level_sequence(hit)
		check(manager.cacao == (10 if hit else 0), "Only a bar hit awards cacao")
		check(manager.collected == 0 and manager.total_collectibles == 0, "Bar does not alter level pickup counts")
		check(goal.get_node("CoinAudio").playing == hit, "Bar hit plays the collectible sound once")
		check(not goal.get_node("Bar/AnimationPlayer").is_playing(), "Goal freezes the moving bar")
		goal.begin_end_level_sequence(true)
		check(manager.cacao == (10 if hit else 0), "Repeated goal triggers do not award twice")
		await process_frame
		goal.free()
		player.free()
	print("Cacao reward checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
