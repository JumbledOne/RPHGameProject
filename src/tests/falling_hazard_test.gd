extends Node

var failures := 0

func _ready() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func block(parent: Node, at: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.position = at
	body.add_child(shape)
	parent.add_child(body)

func drop(hazard: FallingHazard, count: int) -> void:
	for i in count:
		if hazard.state == FallingHazard.State.LANDED:
			break
		hazard._physics_process(1.0 / 60.0)
		await frames(1)

func _run() -> void:
	await check_proximity()
	for path in ["falling_crate/falling_crate", "falling_debris/falling_debris"]:
		for obstacle in ["ceiling", "wall", "wall_floor", "empty", "floor", "edge"]:
			var fixture := Node2D.new()
			add_child(fixture)
			var hazard: FallingHazard = load("res://level_objects/" + path + ".tscn").instantiate()
			fixture.add_child(hazard)
			hazard.set_physics_process(false)
			var half_size: Vector2 = hazard.get_node("CollisionShape2D").shape.size * 0.5
			match obstacle:
				"ceiling": block(fixture, Vector2(0, -half_size.y), Vector2(200, 8))
				"wall": block(fixture, Vector2(half_size.x + 4, 300), Vector2(10, 1000))
				"wall_floor":
					block(fixture, Vector2(half_size.x + 4, 0), Vector2(10, 1000))
					block(fixture, Vector2(0, 200), Vector2(200, 20))
				"floor": block(fixture, Vector2(0, 200), Vector2(200, 20))
				"edge": block(fixture, Vector2(half_size.x - 1, 200), Vector2(2, 20))
			await frames(2)
			hazard.state = FallingHazard.State.FALLING
			await drop(hazard, 120)
			if obstacle in ["floor", "edge", "wall_floor"]:
				check(hazard.state == FallingHazard.State.LANDED, path + " must land on " + obstacle)
				check(absf(hazard.position.y + half_size.y - 190) < 0.5, path + " must rest on the supporting surface")
			else:
				check(hazard.state == FallingHazard.State.FALLING and hazard.position.y > 640, path + " must keep falling past " + obstacle)
			fixture.queue_free()
			await frames(2)
	# Use the authored level's terrain and crate instances without running unrelated level UI.
	var level: Node2D = load("res://scenes/levels/level_3.tscn").instantiate()
	var fixture := Node2D.new()
	add_child(fixture)
	var terrain := level.get_node("TileMapLayer")
	terrain.owner = null
	terrain.reparent(fixture)
	var crates: Array[FallingHazard] = []
	for crate_name in ["FallingCrate", "FallingCrate2"]:
		var crate: FallingHazard = level.get_node("LevelObjects/" + crate_name)
		crate.owner = null
		crate.reparent(fixture)
		crate.set_physics_process(false)
		crates.append(crate)
	level.free()
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	fixture.add_child(player)
	await frames(2)
	for crate in crates:
		var start := crate.position
		player.position = start + Vector2(0, 100)
		crate._physics_process(1.0 / 60.0)
		check(crate.state == FallingHazard.State.FALLING, crate.name + " must fall immediately near the player")
		await drop(crate, 180)
		check(crate.state == FallingHazard.State.LANDED, crate.name + " must reach the level 3 floor")
		check(crate.position.y > start.y + 100, crate.name + " must escape the overhead terrain")
		check(absf(crate.position.y + 16.0) < 0.5, crate.name + " must land on the floor at y=0")
		print(crate.name, " dropped from ", start, " to ", crate.position)
	fixture.queue_free()
	await frames(2)
	print("Falling hazard tests: ", failures, " failures")
	get_tree().quit(0 if failures == 0 else 1)

func check_proximity() -> void:
	for path in ["falling_crate/falling_crate", "falling_debris/falling_debris"]:
		var fixture := Node2D.new()
		add_child(fixture)
		var hazard: FallingHazard = load("res://level_objects/" + path + ".tscn").instantiate()
		fixture.add_child(hazard)
		hazard.set_physics_process(false)
		hazard.warning_time = 3.0
		var player := CharacterBody2D.new()
		player.add_to_group("player")
		fixture.add_child(player)
		player.position = Vector2(0, -100)
		hazard._physics_process(0.01)
		check(hazard.state == FallingHazard.State.WAITING, "Player above must not trigger " + path)
		player.position = Vector2(72, 100)
		hazard._physics_process(0.01)
		check(hazard.state == FallingHazard.State.WARNING, "Outer range must start warning for " + path)
		hazard._physics_process(0.1)
		check(hazard.state == FallingHazard.State.WARNING, "Outer range must preserve warning timer for " + path)
		player.position.x = 48
		hazard._physics_process(0.01)
		check(hazard.state == FallingHazard.State.FALLING, "Close approach must bypass unfinished timer for " + path)
		check(hazard.get_node("Sprite2D").position.x == 0 and hazard._safe_platform.collision_layer == 0, "Early fall must stop shaking and disable platform")
		hazard._physics_process(0.01)
		check(hazard.position.y > 0, "Early fall must move downward")
		hazard.state = FallingHazard.State.WAITING
		player.position.x = -48
		hazard._physics_process(0.01)
		check(hazard.state == FallingHazard.State.FALLING, "Entering close range directly must drop " + path)
		hazard.state = FallingHazard.State.WAITING
		player.position.x = 72
		hazard._physics_process(0.01)
		hazard._physics_process(3.1)
		check(hazard.state == FallingHazard.State.FALLING, "Timer must still drop hazard from outer range")
		fixture.queue_free()
		await frames(2)


