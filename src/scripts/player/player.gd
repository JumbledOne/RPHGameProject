extends CharacterBody2D

@export_category("Movement")
@export var walk_speed: float = 128
@export var walk_acceleration: float = 50
@export var sprint_speed: float = 20
@export var sprint_acceleration: float = 10

@export_category("Jump")
@export var jump_velocity: float = 512
@export var jump_gravity_factor: float = 0.5
@export var jump_max_time: float = 5

@export_category("Physics")
@export var gravity: float = 980

# Controlled by external controllers
# This script decides only how to move.
# Control is in another script
var horizontal_movement: float
var _gravity_factor: float = 1
var _is_sprinting: bool = false
var _last_jump_time: float

const MAX_HEALTH: int = 3
var health: int = MAX_HEALTH:
	set(v):
		var new_health: int = clamp(v, 0, MAX_HEALTH)
		var health_diff: int = new_health - health
		health = new_health
		health_changed.emit(health_diff)
		if health <= 0:
			die()
			
signal died
signal health_changed(diff: int)
signal jumped
signal sprint_changed

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
	var max_acceleration: float = sprint_acceleration if _is_sprinting else walk_acceleration
	
	# Find acceleration
	var target_vel_x: float = horizontal_movement * speed
	var acceleration: float = target_vel_x - velocity.x
	acceleration = min(abs(acceleration), max_acceleration) * sign(acceleration) # Clamps acceleration
	# Apply acceleration
	velocity.x += acceleration
	
	# Gravity
	velocity.y += gravity * delta * _gravity_factor
	
	# Apply
	move_and_slide()

# # # # # # # # # # # #
func begin_jump():
	_last_jump_time = Time.get_ticks_msec()
	velocity.y -= jump_velocity
	_gravity_factor = jump_gravity_factor

func release_jump():
	_gravity_factor = 1
	
# # # # # # # # # # # #
func begin_sprint():
	_is_sprinting = true

func release_sprint():
	_is_sprinting = false
