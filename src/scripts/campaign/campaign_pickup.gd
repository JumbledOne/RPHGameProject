extends Area2D
@export_enum("cacao", "durian", "eagle") var kind := "cacao"
var taken := false
var age := 0.0
var sprite: Sprite2D

func _ready() -> void:
	if sprite == null:
		sprite = get_node_or_null("Sprite2D")
	collision_layer = 0
	collision_mask = 1
	if get_node_or_null("CollisionShape2D") == null:
		var collider := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 19
		collider.shape = circle
		add_child(collider)
	if kind == "cacao":
		LevelManager.register_collectible()
	body_entered.connect(_collect)

func _process(delta: float) -> void:
	age += delta
	if sprite:
		sprite.position.y = sin(age * 3) * 3
		if kind == "eagle":
			sprite.region_rect.position.x = int(age * 6) % 2 * 32

func _collect(body: Node2D) -> void:
	if taken or not body is PlayerEntity:
		return
	taken = true
	match kind:
		"cacao": LevelManager.collect()
		"durian": body.durians += 1
		"eagle": body.eagle_charges += 1
	var sound := AudioStreamPlayer.new()
	sound.volume_db = -12
	get_parent().add_child(sound)
	if kind == "cacao":
		preload("res://assets/audio/audio_resources/coin_effects.tres").play_random_at(sound)
		get_tree().create_timer(1.4).timeout.connect(sound.queue_free)
	else:
		sound.stream = preload("res://assets/audio/sfx/eat.wav")
		sound.finished.connect(sound.queue_free)
		sound.play()
	queue_free()
