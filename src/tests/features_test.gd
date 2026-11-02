extends Node
## A tiny physics fixture validates reusable objects; it is not a game level.
var failures := 0
var fixture: Node2D
var player: PlayerEntity
var features: Node2D

func _ready() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in range(count):
		await get_tree().physics_frame

func spawn(path: String, at: Vector2) -> Node2D:
	var node = load(path).instantiate()
	node.position = at
	features.objects.add_child(node)
	return node

func make_fixture(character: PlayerClass) -> void:
	GameManager.player_class = character
	GameManager.player = null
	LevelManager.start_game(0)
	fixture = Node2D.new()
	get_tree().root.add_child(fixture)
	get_tree().current_scene = fixture
	features = Node2D.new()
	features.set_script(preload("res://scripts/campaign/campaign_level.gd"))
	fixture.add_child(features)
	var body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1280, 64)
	collider.shape = rectangle
	body.position = Vector2(640, 32)
	body.add_child(collider)
	fixture.add_child(body)
	player = load("res://entities/player/player.tscn").instantiate()
	player.position = Vector2(200, -32)
	fixture.add_child(player)
	player.get_node("PlayerController").set_physics_process(false)
	player.horizontal_movement = 0
	await frames(5)

func _run() -> void:
	var classes: Array[PlayerClass] = [UrbanCharacter.new(), AtaCharacter.new(), BagoboCharacter.new()]
	for character in classes:
		await make_fixture(character)
		check(player.health == 3, "Starts with three hearts")
		if character is AtaCharacter:
			check(player.jump_velocity > 512 and player.max_jump_time < 1, "Ata movement buff")
		if character is BagoboCharacter:
			check(player.jump_velocity < 512 and player.max_midair_jumps == 1, "Bagobo double jump")
		spawn("res://level_objects/features/pickups/durian.tscn", player.position)
		await frames(4)
		check(player.durians == 1, "Durian stacks at full health")
		player.hurt(1)
		player.hurt(1)
		check(player.health == 2, "Repeated contacts respect invulnerability")
		player.eat_durian()
		check(player.health == 3 and player.durians == 0, "Eating consumes one fruit and heals one heart")
		spawn("res://level_objects/features/pickups/eagle.tscn", player.position)
		await frames(4)
		player.do_ability()
		check(player.eagle_charges == 0 and player.jump_factor > 1 and player.velocity.y < 0, "Eagle jump boost")
		player.position = Vector2(200, -32)
		player.velocity = Vector2.ZERO
		var cacao = spawn("res://level_objects/features/enemies/cacao.tscn", Vector2(360, -24))
		player.durians = 1
		player.do_attack()
		await frames(30)
		check(player.durians == 0 and cacao.health == 2, "Thrown durian removes exactly one enemy heart")
		player.invulnerability = 0
		cacao.attack_clock = 9.99
		cacao._physics_process(0.02)
		check(player.health == 2, "Cacao poison ticks after ten seconds")
		player.heal(1)
		cacao.queue_free()
		var spikes = spawn("res://level_objects/features/enemies/durian.tscn", player.position + Vector2(30, 0))
		player.invulnerability = 0
		spikes._physics_process(0.02)
		check(player.health == 2 and player.velocity.x < 0, "Evil durian damage and knockback")
		player.heal(1)
		spikes.queue_free()
		var friar = spawn("res://level_objects/features/enemies/spanish.tscn", Vector2(400, -24))
		friar._physics_process(0.01)
		check(features.blind_requested, "Friar obscures vision")
		friar.attack_clock = 2.99
		friar._physics_process(0.02)
		check(not features.blind_requested and not friar.sprite.visible, "Friar clears after three seconds")
		friar.attack_clock = 3.99
		friar._physics_process(0.02)
		check(features.blind_requested and friar.sprite.visible, "Friar returns after one second")
		friar.queue_free()
		for kind in ["japanese", "american"]:
			var shooter = spawn("res://level_objects/features/enemies/%s.tscn" % kind, Vector2(420, -24))
			var count: int = features.objects.get_child_count()
			shooter._physics_process(0.01)
			check(features.objects.get_child_count() == count + 1, "%s fires during burst" % kind)
			count = features.objects.get_child_count()
			shooter.attack_clock = 3.1
			shooter.shot_clock = 0
			shooter._physics_process(0.01)
			check(features.objects.get_child_count() == count, "%s rests after burst" % kind)
			shooter.queue_free()
		var cannon = spawn("res://level_objects/features/cannon.tscn", Vector2(600, -20))
		var count: int = features.objects.get_child_count()
		cannon.clock = cannon.fire_interval
		cannon._physics_process(0.01)
		check(features.objects.get_child_count() == count + 1, "Cannon fires")
		for i in range(15):
			LevelManager.register_collectible()
		LevelManager.add_cacao(15)
		check(LevelManager.get_stars() == 2, "Three stars require boss defeat")
		var boss = spawn("res://level_objects/features/enemies/durian.tscn", Vector2(800, -24))
		boss.boss = true
		boss.hurt(3)
		check(LevelManager.boss_defeated and LevelManager.get_stars() == 3, "Boss plus all cacao earns three stars")
		var exit = spawn("res://level_objects/features/level_exit.tscn", Vector2(1050, -48))
		exit._enter(player)
		await frames(3)
		check(not LevelManager.game_started, "Placeable exit finishes the run")
		GameManager.player = null
		fixture.queue_free()
		await frames(3)
	# Load every authored level without inserting or rearranging content.
	for scene in LevelManager.LEVELS:
		check(scene.can_instantiate(), "Authored level remains loadable")
	print("Feature tests: %s (%d failures; 3 characters, 5 enemy types, pickups, cannon, exit)" % ["PASS" if failures == 0 else "FAIL", failures])
	get_tree().quit(0 if failures == 0 else 1)
