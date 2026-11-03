class_name Ghost
extends Node2D

@export var max_speed: float = 28.0
@export var acceleration_rate: float = 48.0
@export var arrival_distance: float = 3.0

var velocity: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO
var destination: Vector2
var movement_bounds: Rect2
var _last_facing_right: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func initialize(bounds: Rect2, start_position: Vector2, spritesheet: Texture2D) -> void:
	$CharacterSprite.texture = spritesheet
	movement_bounds = bounds
	position = start_position
	destination = position

func move_to_random_floor_position() -> void:
	if movement_bounds.size.x <= 0.0:
		return
	destination = Vector2(
		randf_range(movement_bounds.position.x, movement_bounds.end.x),
		movement_bounds.end.y
	)

func _physics_process(delta: float) -> void:
	if position.distance_to(destination) <= arrival_distance:
		velocity = Vector2.ZERO
		acceleration = Vector2.ZERO
		_play_walking_animation()
		return

	var direction := signf(destination.x - position.x)
	var desired_velocity := Vector2(direction * max_speed, 0.0)
	var previous_velocity := velocity
	velocity = velocity.move_toward(desired_velocity, acceleration_rate * delta)
	acceleration = (velocity - previous_velocity) / maxf(delta, 0.0001)
	position.x = move_toward(position.x, destination.x, absf(velocity.x) * delta)
	position.y = movement_bounds.end.y
	_play_walking_animation()

func _play_walking_animation() -> void:
	if is_zero_approx(velocity.x):
		var idle_animation: StringName = &"face_right" if _last_facing_right else &"face_left"
		if animation_player.current_animation != idle_animation:
			animation_player.play(idle_animation)
		return
	_last_facing_right = velocity.x > 0.0
	var animation: StringName = &"walk_right" if _last_facing_right else &"walk_left"
	if animation_player.current_animation != animation:
		animation_player.play(animation)
