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

var target: Node2D
var desired_pos: Vector2

# These variables are constants so that it is consistent for any level
const CAMERA_Y: float = -148.0 # Tuned such that you can see exactly one tile below the x-axis
const CAMERA_ZOOM: float = 1.0

func _ready() -> void:
	# Define level bounds
	var half_screen_width: float = GameManager.SCREEN_SIZE.x / 2
	left_boundary = GameManager.level_left_boundary + half_screen_width 
	right_boundary = GameManager.level_right_boundary - half_screen_width
	# Connect to player
	GameManager.player_set.connect(_on_player_set)
	# Set initial values
	zoom = Vector2.ONE * CAMERA_ZOOM
	desired_pos.y = CAMERA_Y 
	position.y = CAMERA_Y
	# Start position at player if present
	if GameManager.player:
		desired_pos.x = GameManager.player.global_position.x
		position.x = GameManager.player.global_position.x

func _physics_process(_delta: float) -> void:
	if not target:
		return
	# Move desired pos
	var x_diff: float = target.global_position.x - global_position.x
	if x_diff > dead_zone_right:
		desired_pos.x = target.global_position.x - dead_zone_right
	elif x_diff < dead_zone_left:
		desired_pos.x = target.global_position.x - dead_zone_left
	desired_pos.x = clamp(desired_pos.x, left_boundary, right_boundary)
	# Move to desired pos
	position = floor(lerp(position, desired_pos, lerp_amount))

func _on_player_set():
	target = GameManager.player
	if target:
		desired_pos.x = GameManager.player.global_position.x
		position.x = GameManager.player.global_position.x
