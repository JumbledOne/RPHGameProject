class_name FallingHazard
extends StaticHazard
## One drop per proximity trigger, with a visible warning and offscreen reset.

signal triggered
signal landed

@export_range(16.0, 512.0) var trigger_distance: float = 96.0
@export_range(0.0, 3.0) var warning_time: float = 0.5
@export var fall_gravity: float = 980.0
@export var terminal_speed: float = 600.0
@export var max_fall_distance: float = 640.0

enum State { WAITING, WARNING, FALLING, LANDED }
var state: State = State.WAITING
var _origin: Vector2
var _timer: float = 0.0
var _speed: float = 0.0
var _ground_cast: ShapeCast2D
var _safe_platform: StaticBody2D
var _visible_on_screen_notifier: VisibleOnScreenNotifier2D

func _ready() -> void:
	super()
	_origin = position
	_ground_cast = ShapeCast2D.new()
	_ground_cast.shape = $CollisionShape2D.shape
	_ground_cast.position = $CollisionShape2D.position
	_ground_cast.collision_mask = 1
	add_child(_ground_cast)
	# A one-way solid top lets players land without blocking a falling hazard from below.
	_safe_platform = StaticBody2D.new()
	_safe_platform.collision_layer = 1
	_safe_platform.collision_mask = 0
	var platform_shape := CollisionShape2D.new()
	platform_shape.shape = $CollisionShape2D.shape
	platform_shape.position = $CollisionShape2D.position
	platform_shape.one_way_collision = true
	_safe_platform.add_child(platform_shape)
	add_child(_safe_platform)
	_ground_cast.add_exception(_safe_platform)
	_visible_on_screen_notifier = VisibleOnScreenNotifier2D.new()
	var collision_shape := $CollisionShape2D as CollisionShape2D
	var rectangle := collision_shape.shape as RectangleShape2D
	_visible_on_screen_notifier.rect = Rect2(collision_shape.position - rectangle.size * 0.5, rectangle.size)
	add_child(_visible_on_screen_notifier)
	_visible_on_screen_notifier.screen_exited.connect(_reset_if_offscreen)

func _can_hurt_body(body: Node2D) -> bool:
	if state != State.FALLING or body.global_position.y <= global_position.y:
		return false
	var collision_shape := $CollisionShape2D as CollisionShape2D
	var rectangle := collision_shape.shape as RectangleShape2D
	return absf(body.global_position.x - collision_shape.global_position.x) <= rectangle.size.x * 0.5

func _physics_process(delta: float) -> void:
	super(delta)
	_update_safe_platform()
	match state:
		State.WAITING:
			for player in get_tree().get_nodes_in_group("player"):
				# Horizontal proximity allows objects to hang above the player.
				if absf(player.global_position.x - global_position.x) <= trigger_distance and player.global_position.y > global_position.y:
					_ground_cast.add_exception(player)
					state = State.WARNING
					_timer = warning_time
					InterfaceManager.camera_shake_requested.emit(0.5)
					triggered.emit()
					break
		State.WARNING:
			_timer -= delta
			$Sprite2D.position.x = sin(_timer * 70.0) * 2.0
			if _timer <= 0.0:
				$Sprite2D.position.x = 0.0
				state = State.FALLING
				_update_safe_platform()
		State.FALLING:
			_speed = minf(_speed + fall_gravity * delta, terminal_speed)
			_ground_cast.target_position = Vector2(0, _speed * delta)
			_ground_cast.force_shapecast_update()
			position.y += _speed * delta * _ground_cast.get_closest_collision_safe_fraction()
			if _ground_cast.is_colliding() or position.y - _origin.y >= max_fall_distance:
				state = State.LANDED
				_update_safe_platform()
				landed.emit()
		State.LANDED:
			_reset_if_offscreen()

func _reset_if_offscreen() -> void:
	if state != State.LANDED or _visible_on_screen_notifier.is_on_screen():
		return
	position = _origin
	_speed = 0.0
	_cooldowns.clear()
	_ground_cast.clear_exceptions()
	_ground_cast.add_exception(_safe_platform)
	state = State.WAITING
	_update_safe_platform()

func _update_safe_platform() -> void:
	_safe_platform.collision_layer = 0 if state == State.FALLING else 1
