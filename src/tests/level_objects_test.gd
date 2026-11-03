extends SceneTree

class TestPlayer extends CharacterBody2D:
	var hits: int = 0
	var simulate: bool = false
	func hurt(_amount: int = 1) -> void:
		hits += 1
	func _physics_process(delta: float) -> void:
		if simulate:
			velocity.y += 980.0 * delta
			move_and_slide()

var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func object_at(path: String, location: Vector2) -> Node2D:
	var instance: Node2D = load("res://level_objects/" + path + ".tscn").instantiate()
	if instance is MovingPlatform:
		instance.start_on_screen = false
	instance.position = location
	root.add_child(instance)
	return instance

func _run() -> void:
	var player := TestPlayer.new()
	player.add_to_group("player")
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(12, 24)
	shape.shape = rectangle
	player.add_child(shape)
	root.add_child(player)
	var cannon := object_at("features/cannon", Vector2(0, 100))
	player.position = Vector2(0, 30)
	player.simulate = true
	await frames(30)
	check(player.is_on_floor(), "Player must land on the cannon")
	player.velocity.x = 30.0
	await frames(20)
	check(player.is_on_floor() and player.position.x > 5.0, "Player must walk across the cannon top")
	player.simulate = false
	player.position = Vector2(-80, 100)
	var side_hit := player.move_and_collide(Vector2(80, 0))
	check(side_hit != null and side_hit.get_normal().x < -0.5, "Cannon side must block the player")
	var scene_placer := root.get_node("ScenePlacer")
	scene_placer.level_objects = root
	var shot: Projectile = cannon.get_node("Weapon").fire(-1.0)
	await frames(5)
	check(is_instance_valid(shot) and not shot.spent and shot.global_position.x < -48.0, "Cannonball must clear the solid cannon")
	if is_instance_valid(shot):
		shot.queue_free()
	scene_placer.level_objects = null
	cannon.queue_free()
	player.velocity = Vector2.ZERO
	await frames(2)
	player.position = Vector2(0, 0)
	var spikes := object_at("spike_barricade/spike_barricade", Vector2.ZERO)
	await frames(5)
	check(player.hits == 1, "Static hazard must damage once on contact")
	await frames(10)
	check(player.hits == 1, "Static hazard cooldown must prevent per-frame damage")
	spikes.queue_free()
	player.position = Vector2(1000, 1000)
	var moving := object_at("river_boat/river_boat", Vector2(0, 100))
	await frames(20)
	check(moving.position.x < 0, "Moving platform must travel from its placed origin")
	moving.queue_free()
	var platform := object_at("moving_car/moving_car", Vector2(0, 100))
	platform.moving = false
	player.position = Vector2(0, 44)
	player.velocity = Vector2.ZERO
	player.simulate = true
	var previous_hits := player.hits
	await frames(30)
	check(player.is_on_floor(), "Player must be able to stand on a hazard platform")
	check(player.hits == previous_hits, "Standing on top must be safe")
	platform.moving = true
	var rider_start := player.position.x
	await frames(20)
	check(absf(player.position.x - rider_start) > 5.0, "Moving platform must carry its passenger")
	check(player.hits == previous_hits, "Riding a moving hazard platform must be safe")
	platform.moving = false
	player.simulate = false
	player.position = platform.position + Vector2(116, 0)
	await frames(5)
	check(player.hits > previous_hits, "Hazard platform side must hurt")
	platform.queue_free()
	var cannonball := object_at("rolling_cannonball/rolling_cannonball", Vector2(0, 100))
	cannonball.moving = false
	player.position = Vector2(14, 100)
	player.velocity = Vector2.ZERO
	previous_hits = player.hits
	await frames(5)
	check(player.hits == previous_hits and player.velocity.x > 0, "Cannonballs must push without damage")
	cannonball.queue_free()
	player.position = Vector2(1000, 1000)
	var floating := object_at("floating_driftwood/floating_driftwood", Vector2(0, 100))
	floating.speed = 0.0
	await frames(20)
	check(absf(floating.position.y - 100.0) > 0.1, "Floating platform must bob vertically")
	player.position = floating.position + Vector2(0, -24)
	player.velocity = Vector2.ZERO
	player.simulate = true
	previous_hits = player.hits
	await frames(90)
	check(player.is_on_floor(), "Player must stay on a bobbing platform")
	check(player.hits == previous_hits, "Riding a bobbing platform must be safe")
	player.simulate = false
	player.position = Vector2(1000, 1000)
	floating.queue_free()
	var falling := object_at("falling_crate/falling_crate", Vector2(0, -100))
	falling.warning_time = 0.1
	await frames(5)
	check(falling.state == FallingHazard.State.WAITING, "Distant player must not trigger falling hazard")
	var ground := StaticBody2D.new()
	var ground_shape := CollisionShape2D.new()
	var ground_rect := RectangleShape2D.new()
	ground_rect.size = Vector2(200, 20)
	ground_shape.shape = ground_rect
	ground.position = Vector2(0, 60)
	ground.add_child(ground_shape)
	root.add_child(ground)
	var has_landed := [false]
	falling.landed.connect(func(): has_landed[0] = true)
	player.position = Vector2(72, 0)
	await frames(3)
	check(falling.state == FallingHazard.State.WARNING, "Nearby player must trigger warning")
	player.position = Vector2(1000, 1000)
	await frames(80)
	check(has_landed[0], "Falling hazard must land on ground")
	check(falling.state == FallingHazard.State.LANDED, "Visible falling hazard must stay landed")
	falling.position = Vector2(10000, 10000)
	await frames(5)
	check(falling.state == FallingHazard.State.WAITING and falling.position == Vector2(0, -100), "Falling hazard must reset after leaving the screen")
	falling.queue_free()
	ground.queue_free()
	for path in ["falling_crate/falling_crate", "falling_debris/falling_debris"]:
		var safe_falling := object_at(path, Vector2(200, 100))
		player.position = Vector2(200, 30)
		player.velocity = Vector2.ZERO
		player.simulate = true
		previous_hits = player.hits
		await frames(45)
		check(player.is_on_floor(), path + " must support a player while waiting")
		check(player.hits == previous_hits, path + " must be safe to stand on")
		safe_falling.state = FallingHazard.State.LANDED
		await frames(5)
		check(player.is_on_floor() and player.hits == previous_hits, path + " must support a player after landing")
		player.simulate = false
		player.position = Vector2(1000, 1000)
		safe_falling.queue_free()
		await frames(2)
	var damage_falling := object_at("falling_crate/falling_crate", Vector2(200, 100))
	damage_falling.fall_gravity = 0.0
	damage_falling.terminal_speed = 0.0
	player.position = Vector2(200, 110)
	previous_hits = player.hits
	await frames(5)
	check(player.hits == previous_hits, "Warning falling hazard must be harmless")
	damage_falling.state = FallingHazard.State.FALLING
	player.position = Vector2(200, 90)
	await frames(5)
	check(player.hits == previous_hits, "Falling hazard must be harmless above the object")
	player.position = Vector2(218, 110)
	await frames(5)
	check(player.hits == previous_hits, "Side contact with a falling hazard must be harmless")
	player.position = Vector2(200, 110)
	await frames(5)
	check(player.hits == previous_hits + 1, "Falling hazard must hurt a player underneath it")
	damage_falling.state = FallingHazard.State.LANDED
	damage_falling._cooldowns.clear()
	await frames(5)
	check(player.hits == previous_hits + 1, "Landed falling hazard must be harmless")
	damage_falling.queue_free()
	player.queue_free()
	await frames(2)
	print("Level object tests: ", "PASS" if failures == 0 else "FAIL", " (", failures, " failures)")
	quit(0 if failures == 0 else 1)
