class_name Enemy_Entity
extends Entity

@export var boss := false
@export var activation_range := 440.0
@export var movement_radius := 220.0
@export var animation_row := 0

var age := 0.0
var attack_clock := 0.0
var active := false
var origin := Vector2.ZERO
var flash := 0.0
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var controller: EnemyController = get_node_or_null("EnemyController")
@onready var health_display: HBoxContainer = get_node_or_null("HealthDisplay")

func _init() -> void:
	# Enemies are one-hit by default; individual scenes can override max_health.
	max_health = 1
	health = 1

func _ready() -> void:
	# Apply any scene-level max_health override to the starting health.
	health = max_health
	add_to_group("enemies")
	origin = position
	collision_layer = 1
	collision_mask = 1
	if health_display:
		health_display.link_entity(self)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var player := GameManager.player
	if not is_instance_valid(player) or not LevelManager.game_started:
		return
	var was_active := active
	active = absf(player.global_position.x - global_position.x) < activation_range
	if not active:
		attack_clock = 0.0
		if was_active and controller:
			controller.deactivated()
		return
	if not was_active and controller:
		controller.activated()
	age += delta
	attack_clock += delta
	flash = maxf(flash - delta, 0.0)
	if sprite:
		sprite.modulate = Color(2, 0.5, 0.5) if flash > 0 else Color.WHITE
		var direction := signf(player.global_position.x - global_position.x)
		sprite.flip_h = direction > 0
		sprite.region_rect = Rect2(int(age * 6) % 3 * 32, animation_row * 64, 32, 64)
	velocity.y += 1960 * delta
	if controller:
		controller.tick(delta, player, signf(player.global_position.x - global_position.x))
	move_and_slide()
	position.x = clampf(position.x, origin.x - movement_radius, origin.x + movement_radius)

func hurt(amount: int = 1, damage_type: DAMAGE_TYPES = DAMAGE_TYPES.GENERIC) -> void:
	if is_queued_for_deletion():
		return
	flash = 0.16
	super(amount, damage_type)

func die() -> void:
	if is_queued_for_deletion():
		return
	LevelManager.add_score(500 if boss else 200)
	if boss:
		LevelManager.boss_defeated = true
	super()
