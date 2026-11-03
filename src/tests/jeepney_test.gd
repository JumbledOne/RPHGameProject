extends SceneTree

const JEEPNEY := preload("res://level_objects/jeepney/jeepney.tscn")
var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	var jeepney := JEEPNEY.instantiate()
	# Allow deterministic manual physics steps outside the physics callback.
	jeepney.sync_to_physics = false
	jeepney.position = Vector2(10000, 10000)
	jeepney.velocity = -120.0
	root.add_child(jeepney)
	var sound: AudioStreamPlayer = jeepney.get_node("AppearSound")
	var running_sound: AudioStreamPlayer = jeepney.get_node("RunningSound")
	var sprite: Sprite2D = jeepney.get_node("Sprite2D")
	var texture: AtlasTexture = sprite.texture
	check(not jeepney.enabled and not sound.playing, "Offscreen jeepney must wait silently")
	check(not running_sound.playing, "Running sound must wait for activation")
	check(running_sound.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Running sound must loop")
	var origin: Vector2 = jeepney.position
	jeepney._physics_process(0.5)
	check(jeepney.position == origin, "Offscreen jeepney must remain stationary")
	check(sprite.flip_h, "Negative velocity must face left")
	check(jeepney.TEXTURE_REGIONS.has(texture.region), "Texture must use a jeepney atlas variant")
	check(jeepney.has_node("LeftHazard") and jeepney.has_node("RightHazard"), "Jeepney must retain moving-car side hazards")
	jeepney._on_screen_entered()
	check(jeepney.enabled and sound.playing, "Screen entry must activate movement and sound")
	check(running_sound.playing, "Activation must start the running sound")
	jeepney._physics_process(0.5)
	check(jeepney.position == origin + Vector2(-60, 0), "Signed velocity must control travel")
	sound.stop()
	jeepney.enable_movement()
	check(not sound.playing, "Repeated activation must not replay sound")
	jeepney.velocity = 80.0
	check(not sprite.flip_h, "Positive velocity must face right")
	origin = jeepney.position
	jeepney._physics_process(0.5)
	check(jeepney.position == origin + Vector2(40, 0), "Changing velocity must update movement")
	jeepney.velocity = 0.0
	origin = jeepney.position
	jeepney._physics_process(0.5)
	check(jeepney.position == origin, "Zero velocity must stop movement")
	check(not running_sound.playing, "Zero velocity must stop the running sound")
	jeepney.velocity = 80.0
	jeepney._physics_process(0.5)
	check(running_sound.playing, "Resuming movement must resume the running sound")
	jeepney.moving = false
	jeepney._physics_process(0.5)
	check(not running_sound.playing, "Disabling movement must stop the running sound")
	var variants: Dictionary = {}
	for i in 64:
		var other := JEEPNEY.instantiate()
		other.start_on_screen = false
		root.add_child(other)
		var other_texture: AtlasTexture = other.get_node("Sprite2D").texture
		variants[other_texture.region] = true
		check(other_texture != texture, "Instances must have independent atlas textures")
		check(other.enabled and other.get_node("AppearSound").playing, "Immediate activation must play sound")
		other.free()
	check(variants.size() == 3, "Randomization must cover all three atlas variants")
	jeepney.free()
	await process_frame
	await process_frame
	print("Jeepney tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)
