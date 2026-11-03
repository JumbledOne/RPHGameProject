extends SceneTree

const DRIFTWOOD := preload("res://level_objects/floating_driftwood/floating_driftwood.tscn")
var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	var fixture := Node2D.new()
	root.add_child(fixture)
	var wood := DRIFTWOOD.instantiate()
	wood.sync_to_physics = false
	wood.position = Vector2(200, 100)
	fixture.add_child(wood)
	wood.set_physics_process(false)
	var edge_transform: Transform2D = wood.transform
	edge_transform.origin.x = -wood.get_node("Sprite2D").get_rect().size.x * 0.5 + 1.0
	check(wood._is_on_screen(edge_transform), "A visible sprite edge must count as on screen")
	wood._physics_process(0.1)
	check(wood.enabled, "Visible driftwood must activate")
	check(wood.position.x < 200, "Activated driftwood must move")
	wood.position.x = -1000
	wood._physics_process(0.1)
	check(wood.enabled and wood.position.x < -1000, "Visible origin must prevent an offscreen reset")
	fixture.position.x = -2000
	wood.position.x = 2200
	wood._physics_process(0.1)
	check(wood.enabled and wood.position.x > 2000, "Visible driftwood must not reset when its origin is offscreen")
	wood.position.x = -1000
	wood._physics_process(0.1)
	check(wood.position == Vector2(200, 100), "Both positions offscreen must reset to the placed origin")
	check(not wood.enabled and wood._elapsed == 0.0, "Reset must re-arm activation and reset bobbing")
	wood._physics_process(1.0)
	check(wood.position == Vector2(200, 100) and not wood.enabled, "Reset driftwood must wait offscreen")
	fixture.position = Vector2.ZERO
	wood._physics_process(0.1)
	check(wood.enabled and wood.position.x < 200, "Returning to the origin must restart movement")
	wood.speed = 0.0
	wood.bob_height = 0.0
	fixture.position.x = -2000
	wood.position.x = 300
	wood._physics_process(0.1)
	check(wood.enabled and wood.position.x == 300, "Stationary driftwood must not reset")
	wood.bob_height = 5.0
	wood._physics_process(0.1)
	check(not wood.enabled and wood.position == Vector2(200, 100), "Bobbing alone must qualify as movement for reset")
	var waiting := DRIFTWOOD.instantiate()
	waiting.sync_to_physics = false
	waiting.position = Vector2(10000, 10000)
	fixture.add_child(waiting)
	waiting.set_physics_process(false)
	waiting._physics_process(1.0)
	check(not waiting.enabled and waiting.position == Vector2(10000, 10000), "New offscreen driftwood must wait at its placed origin")
	fixture.free()
	# Exercise the scene's real AnimatableBody2D physics synchronization.
	var live_wood := DRIFTWOOD.instantiate()
	live_wood.position = Vector2(300, 100)
	live_wood.speed = 128.0
	root.add_child(live_wood)
	for i in 30:
		await physics_frame
	await process_frame
	check(live_wood.position.x < 260.0, "Synchronized driftwood at speed 128 must move left during real physics frames")
	check(absf(live_wood.position.y - 100.0) > 1.0, "Synchronized driftwood must keep bobbing while moving horizontally")
	live_wood.queue_free()
	await process_frame
	await process_frame
	print("Driftwood reset tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
