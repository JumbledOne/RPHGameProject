class_name Enemy_Entity
extends Entity

@onready var behaviorManager: Enemy_Behavior = get_node_or_null("BehaviorManager") as Enemy_Behavior
@onready var animatedSprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

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
var _uses_campaign_behavior := false

# Game stuff
var is_jumping: bool = false
var jump_timer: float = 0.0

@export_category("Enemy stats")
@export var speed = 200.0
@export var jump_duration: float = 0.25
@export var jump_speed: float = -300.0

func start_jump() -> void:
	if not is_jumping:
		is_jumping = true
		jump_timer = jump_duration

func _ready() -> void:
	_uses_campaign_behavior = get_node_or_null("AnimatedSprite2D") == null
	if _uses_campaign_behavior:
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
		sprite = get_node_or_null("Sprite2D") as Sprite2D
		if sprite == null:
			sprite = Sprite2D.new()
			add_child(sprite)
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 32, 64)
		sprite.position.y = -8
		health_display = get_node_or_null("HealthDisplay") as HBoxContainer
		if health_display == null:
			health_display = preload("res://scripts/health_display/health_display.tscn").instantiate()
			add_child(health_display)
		health_display.link_entity(self)
		return
	if behaviorManager == null:
		return
	if behaviorManager.attack_Component:
		behaviorManager.attack_Component.animation_request.connect(_change_animation)
	if behaviorManager.movement_Component:
		behaviorManager.movement_Component.flip_sprite.connect(_flip_sprite)

func _process(delta: float) -> void:
	if _uses_campaign_behavior:
		return
	if behaviorManager == null:
		return
	if !behaviorManager.attack_Component:
		return
	
	behaviorManager.attack_Component.tick(self, delta)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _uses_campaign_behavior:
		_campaign_physics_process(delta)
		return
	if behaviorManager == null:
		return
	
	if !behaviorManager.movement_Component:
		return
	
	behaviorManager.movement_Component.tick(self, delta)
	move_and_slide()


func get_activation_range() -> float:
	return activation_range

func _on_activated() -> void:
	pass

func _on_deactivated() -> void:
	pass

func _update_enemy(_delta: float, _player: PlayerEntity, _direction: float) -> void:
	pass

func _campaign_physics_process(delta: float) -> void:
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

func hurt(amount: int = 1, damage_type: DAMAGE_TYPES = DAMAGE_TYPES.GENERIC) -> void:
	if _uses_campaign_behavior:
		if is_queued_for_deletion():
			return
		flash = 0.16
	super(amount, damage_type)

func die() -> void:
	if not _uses_campaign_behavior:
		super()
		return
	if is_queued_for_deletion():
		return
	LevelManager.add_score(500 if boss else 200)
	if boss:
		LevelManager.boss_defeated = true
	super()


#signals
func _flip_sprite(direction: bool) -> void:
	$AnimatedSprite2D.flip_h = direction

func _change_animation(animation_name: String) -> void:
	$AnimatedSprite2D.play(animation_name)
