extends CharacterBody2D

@export_category("Movement")
@export var walk_speed: float = 128
@export var walk_time_to_full_speed: float = 1
@export var sprint_speed: float = 256
@export var sprint_time_to_full_speed: float = 1

@export_category("Jump")
@export var jump_velocity: float = 512
@export var jump_gravity_factor: float = 0.4
@export var jump_buffer: float = 0.1 # In seconds
@export var coyote_time: float = 0.1 # In seconds
@export var max_fall_speed: float = 980

@export_category("Physics")
@export var gravity: float = 980

@export_category("World")
@export var death_y: float = 128 # Below this point the player dies

# Health
const MAX_HEALTH: int = 3
var health: int = MAX_HEALTH:
	set(v):
		var new_health: int = clamp(v, 0, MAX_HEALTH)
		var health_diff: int = new_health - health
		health = new_health
		health_changed.emit(health_diff)
		if health <= 0:
			die()

# Controlled by external controllers
# This script decides only how to move.
# Control is in another script
var horizontal_movement: float
var _is_sprinting: bool = false
var _has_jumped: bool = false
var _walk_acceleration: float
var _sprint_acceleration: float

# Internal vars
var _gravity_factor: float = 1
var _last_jump_time: float # In milliseconds
var _last_on_floor: float # In milliseconds
var _was_on_floor: bool = false:
	set(v):
		if v and not _was_on_floor:
			_landed_on_floor()
		elif not v and _was_on_floor:
			_left_floor()
		_was_on_floor = v
			
signal died
signal health_changed(diff: int)
signal jumped
signal sprint_changed

func _ready() -> void:
	_walk_acceleration = walk_speed / walk_time_to_full_speed
	_sprint_acceleration = sprint_speed / sprint_time_to_full_speed

# # # # # # # # # # # #
# Health
func die():
	died.emit()
	queue_free()

# # # # # # # # # # # #
# Movement
func _physics_process(delta: float) -> void:
	# Movement
	var speed: float = sprint_speed if _is_sprinting else walk_speed
	var max_acceleration: float = _sprint_acceleration if _is_sprinting else _walk_acceleration
	
	# Find acceleration
	var target_vel_x: float = horizontal_movement * speed
	var acceleration: float = target_vel_x - velocity.x
	acceleration *= max_acceleration
	acceleration = min(abs(acceleration), max_acceleration) * sign(acceleration) # Clamps acceleration
	
	# Apply acceleration
	velocity.x += acceleration * delta
	# Gravity
	velocity.y = min(velocity.y + gravity * delta * _gravity_factor, max_fall_speed)
	# Final stuff
	move_and_slide()
	_was_on_floor = is_on_floor()
	if position.y >= death_y:
		die()

# # # # # # # # # # # #
func begin_jump():
	# Check if coyote time can apply
	# Should not work if already jumped
	var _can_coyote_time: bool = false
	if not _has_jumped:
		_can_coyote_time = _get_seconds_since(_last_on_floor) < coyote_time
	if is_on_floor() or _can_coyote_time:
		_has_jumped = true
		velocity.y = min(velocity.y, -jump_velocity)
		_gravity_factor = jump_gravity_factor
		jumped.emit()
	else:
		# For jump buffering
		_last_jump_time = Time.get_ticks_msec()

func release_jump():
	_gravity_factor = 1
	
# # # # # # # # # # # #
func begin_sprint():
	_is_sprinting = true
	sprint_changed.emit()

func release_sprint():
	_is_sprinting = false
	sprint_changed.emit()
	
# # # # # # # # # # # #
func _landed_on_floor():
	# Jump buffering
	if _get_seconds_since(_last_jump_time) < jump_buffer:
		begin_jump()
		return
	_has_jumped = false
	
func _left_floor():
	_last_on_floor = Time.get_ticks_msec()
	
# # # # # # # # # # # #
# Helpers
func _get_seconds_since(time_msec: float) -> float:
	return (Time.get_ticks_msec() - time_msec) / 1000
