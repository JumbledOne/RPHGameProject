class_name FallingHazard
extends StaticHazard
## One drop per proximity trigger, with a visible warning and automatic reset.

signal triggered
signal landed

@export_range(16.0, 512.0) var trigger_distance: float = 96.0
@export_range(0.0, 3.0) var warning_time: float = 0.5
@export var fall_gravity: float = 980.0
@export var terminal_speed: float = 600.0
@export_range(0.1, 30.0) var reset_delay: float = 3.0
@export var max_fall_distance: float = 640.0

enum State { WAITING, WARNING, FALLING, LANDED }
var state: State = State.WAITING
var _origin: Vector2
var _timer: float = 0.0
var _speed: float = 0.0
var _ground_cast: ShapeCast2D

func _ready() -> void:
	super()
	_origin = position
	_ground_cast = ShapeCast2D.new()
	_ground_cast.shape = $CollisionShape2D.shape
	_ground_cast.position = $CollisionShape2D.position
	_ground_cast.collision_mask = 1
	add_child(_ground_cast)

func _physics_process(delta: float) -> void:
	super(delta)
	match state:
		State.WAITING:
			for player in get_tree().get_nodes_in_group("player"):
				# Horizontal proximity allows objects to hang above the player.
				if absf(player.global_position.x - global_position.x) <= trigger_distance and player.global_position.y > global_position.y:
					_ground_cast.add_exception(player)
					state = State.WARNING
					_timer = warning_time
					triggered.emit()
					break
		State.WARNING:
			_timer -= delta
			$Sprite2D.position.x = sin(_timer * 70.0) * 2.0
			if _timer <= 0.0:
				$Sprite2D.position.x = 0.0
				state = State.FALLING
		State.FALLING:
			_speed = minf(_speed + fall_gravity * delta, terminal_speed)
			_ground_cast.target_position = Vector2(0, _speed * delta)
			_ground_cast.force_shapecast_update()
			position.y += _speed * delta * _ground_cast.get_closest_collision_safe_fraction()
			if _ground_cast.is_colliding() or position.y - _origin.y >= max_fall_distance:
				state = State.LANDED
				_timer = reset_delay
				landed.emit()
		State.LANDED:
			_timer -= delta
			if _timer <= 0.0:
				position = _origin
				_speed = 0.0
				_cooldowns.clear()
				_ground_cast.clear_exceptions()
				state = State.WAITING
