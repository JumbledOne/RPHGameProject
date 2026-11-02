class_name PlayerCamera
extends Camera2D
# Do not use position smoothing in this camera!
# Uses custom smoothing logic

@export var dead_zone_right: float = 16 # In px
@export var dead_zone_left: float = -32 # In px
@export var lerp_amount: float = 0.2
@export var screen_width: float = 640

# Level boundaries
var left_boundary: float = -INF
var right_boundary: float = INF

# Target and movement
var target: Node2D
var desired_pos: Vector2

# Shake
var shake: float = 0
const SHAKE_DECAY: float = 1
const MAX_SHAKE: float = 1

# These variables are constants so that it is consistent for any level
const CAMERA_Y: float = -148.0 # Tuned such that you can see exactly one tile below the x-axis
const CAMERA_ZOOM: float = 1.0

func _ready() -> void:
	InterfaceManager.camera_shake_requested.connect(_on_camera_shake_requested)
	# Define level bounds
	var half_screen_width: float = GameManager.SCREEN_SIZE.x / 2
	left_boundary = LevelManager.level_left_boundary + half_screen_width 
	right_boundary = LevelManager.level_right_boundary - half_screen_width
	# Connect to player
	GameManager.player_set.connect(_on_player_set)
	# Set initial values
	zoom = Vector2.ONE * CAMERA_ZOOM
	desired_pos.y = CAMERA_Y 
	position.y = CAMERA_Y
	# Start position at player if present
	if GameManager.player:
		_on_player_set()

func _physics_process(delta: float) -> void:
	if not target:
		return
	_update_desired_position()
	# Move toward the desired position.
	position.x = floor(lerp(position.x, desired_pos.x, lerp_amount))
	# Shake
	if shake > 0.1:
		var shake_offset: Vector2 = Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
		offset = lerp(offset, shake_offset, 0.1)
		shake = move_toward(shake, 0.0, SHAKE_DECAY * delta)
	else:
		shake = 0.0
		offset = Vector2.ZERO

func _on_camera_shake_requested(amount: float) -> void:
	shake = clampf(maxf(shake, amount), 0.0, MAX_SHAKE)

func _update_desired_position() -> void:
	var x_diff: float = target.global_position.x - global_position.x
	if x_diff > dead_zone_right:
		desired_pos.x = target.global_position.x - dead_zone_right
	elif x_diff < dead_zone_left:
		desired_pos.x = target.global_position.x - dead_zone_left
	desired_pos.x = clamp(desired_pos.x, left_boundary, right_boundary)

func _on_player_set():
	target = GameManager.player
	if target:
		_update_desired_position()
		position.x = desired_pos.x
