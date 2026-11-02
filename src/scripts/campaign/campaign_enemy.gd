extends Entity
@export_enum("cacao", "durian", "spanish", "japanese", "american") var kind := "cacao"
@export var boss := false
@export var activation_range: float = 440.0
@export var move_speed: float = 65.0
@export var movement_radius: float = 220.0
@export var poison_interval: float = 10.0
@export var burst_duration: float = 3.0
@export var burst_rest: float = 2.0
@export var shot_interval: float = 0.75
var age := 0.0
var attack_clock := 0.0
var shot_clock := 0.0
var active := false
var origin := Vector2.ZERO
var sprite: Sprite2D
var health_label: Label
var level: Node2D
var flash := 0.0

func _ready() -> void:
	add_to_group("enemies")
	origin = position
	collision_layer = 1
	collision_mask = 1
	if get_node_or_null("CollisionShape2D") == null:
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(24, 48)
		shape.shape = rectangle
		add_child(shape)
	sprite = get_node_or_null("Sprite2D")
	if sprite == null:
		sprite = Sprite2D.new()
		add_child(sprite)
	sprite.texture = load(_texture_path())
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, 32, 64)
	sprite.position.y = -8
	health_label = Label.new()
	health_label.position = Vector2(-60, -63)
	health_label.size.x = 120
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_label.add_theme_font_size_override("font_size", 12)
	health_label.add_theme_color_override("font_outline_color", Color.BLACK)
	health_label.add_theme_constant_override("outline_size", 4)
	add_child(health_label)
	_update_health()

func _texture_path() -> String:
	var base := "res://assets/gfx/sprites/"
	match kind:
		"cacao": return base + "cacaorotten.png"
		"durian": return base + "durianevil.png"
		"spanish": return base + "character_spritesheets/friarspanishenemy.png"
		"japanese": return base + "character_spritesheets/Japanese_Colonizer_Sprite.png"
	return base + "character_spritesheets/American_Colonizer_Sprite.png"

func _physics_process(delta: float) -> void:
	var player := GameManager.player
	if not is_instance_valid(player) or not LevelManager.game_started:
		return
	if not is_instance_valid(level):
		level = get_tree().get_first_node_in_group("level_features")
	if not is_instance_valid(level):
		return
	active = absf(player.global_position.x - global_position.x) < activation_range
	if not active:
		attack_clock = 0
		return
	age += delta
	attack_clock += delta
	flash = maxf(flash - delta, 0)
	sprite.modulate = Color(2, 0.5, 0.5) if flash > 0 else Color.WHITE
	var direction := signf(player.global_position.x - global_position.x)
	sprite.flip_h = direction > 0
	# Existing sheets provide three poses in each 32 by 64 row.
	var row := 0 if kind in ["cacao", "durian"] else 1
	sprite.region_rect = Rect2(int(age * 6) % 3 * 32, row * 64, 32, 64)
	velocity.y += 1960 * delta
	if kind == "durian":
		velocity.x = direction * move_speed if absf(to_local(player.global_position).x) < 300 else 0.0
		if player.global_position.distance_to(global_position) < 45:
			player.hurt(1)
			player.velocity += Vector2(direction * 210, -110)
	elif kind == "cacao":
		if attack_clock >= poison_interval:
			player.hurt(1)
			attack_clock = 0
		health_label.text = "%s  %d/3  • poison %ds" % ["BOSS" if boss else "Cacao", health, ceili(poison_interval - attack_clock)]
	elif kind == "spanish":
		# Three seconds obscured followed by one second of clear vision.
		level.blind_requested = fmod(attack_clock, 4.0) < 3.0
		sprite.visible = fmod(attack_clock, 4.0) < 3.0
	else:
		# A three-second burst, then two seconds of recovery.
		shot_clock -= delta
		if fmod(attack_clock, burst_duration + burst_rest) < burst_duration and shot_clock <= 0:
			level.fire_projectile(global_position + Vector2(direction * 24, -8), direction, kind)
			shot_clock = shot_interval
	move_and_slide()
	position.x = clampf(position.x, origin.x - movement_radius, origin.x + movement_radius)

func hurt(amount: int = 1) -> void:
	if is_queued_for_deletion():
		return
	flash = 0.16
	super(amount)
	_update_health()

func _update_health() -> void:
	if health_label:
		health_label.text = "%s %d/3" % ["BOSS" if boss else kind.capitalize(), health]

func die() -> void:
	if is_queued_for_deletion():
		return
	LevelManager.add_score(500 if boss else 200)
	if boss:
		LevelManager.boss_defeated = true
	super()
