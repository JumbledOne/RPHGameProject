class_name CampaignEnemy
extends Entity
## Shared movement, animation, health and activation for campaign enemies.

@export var boss := false
@export var activation_range: float = 440.0
@export var movement_radius: float = 220.0
@export var animation_row: int = 0

var age := 0.0
var attack_clock := 0.0
var active := false
var origin := Vector2.ZERO
var sprite: Sprite2D
var health_display: HBoxContainer
var level: LevelFeatures
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
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, 32, 64)
	sprite.position.y = -8
	health_display = get_node_or_null("HealthDisplay")
	if health_display == null:
		health_display = preload("res://scripts/health_display/health_display.tscn").instantiate()
		add_child(health_display)
	health_display.link_entity(self)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var player := GameManager.player
	if not is_instance_valid(player) or not LevelManager.game_started:
		return
	if not is_instance_valid(level):
		level = get_tree().get_first_node_in_group("level_features") as LevelFeatures
	if not is_instance_valid(level):
		return
	var was_active := active
	active = absf(player.global_position.x - global_position.x) < get_activation_range()
	if not active:
		attack_clock = 0.0
		_on_deactivated()
		return
	if not was_active:
		_on_activated()
	age += delta
	attack_clock += delta
	flash = maxf(flash - delta, 0.0)
	sprite.modulate = Color(2, 0.5, 0.5) if flash > 0 else Color.WHITE
	var direction := signf(player.global_position.x - global_position.x)
	sprite.flip_h = direction > 0
	sprite.region_rect = Rect2(int(age * 6) % 3 * 32, animation_row * 64, 32, 64)
	velocity.y += 1960 * delta
	_update_enemy(delta, player, direction)
	move_and_slide()
	position.x = clampf(position.x, origin.x - movement_radius, origin.x + movement_radius)

func get_activation_range() -> float:
	return activation_range

func _on_activated() -> void:
	pass

func _on_deactivated() -> void:
	pass

func _update_enemy(_delta: float, _player: PlayerEntity, _direction: float) -> void:
	pass

func hurt(amount: int = 1) -> void:
	if is_queued_for_deletion():
		return
	flash = 0.16
	super(amount)

func die() -> void:
	if is_queued_for_deletion():
		return
	LevelManager.add_score(500 if boss else 200)
	if boss:
		LevelManager.boss_defeated = true
	super()
