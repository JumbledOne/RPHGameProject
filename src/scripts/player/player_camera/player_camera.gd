extends Camera2D
# Do not use position smoothing in this camera!
# Uses custom smoothing logic

@export var target: Node2D
@export var dead_zone_right: float = 16 # In px
@export var dead_zone_left: float = -32 # In px
@export var lerp_amount: float = 0.2

var desired_pos: Vector2

func _ready() -> void:
	GameManager.player_set.connect(_on_player_set)
	desired_pos.y = position.y

func _physics_process(_delta: float) -> void:
	print(position.x)
	if not target:
		return
	# Move desired pos
	var x_diff: float = target.global_position.x - global_position.x
	if x_diff > dead_zone_right:
		desired_pos.x = target.global_position.x - dead_zone_right
	elif x_diff < dead_zone_left:
		desired_pos.x = target.global_position.x - dead_zone_left
	# Move to desired pos
	position = floor(lerp(position, desired_pos, lerp_amount))

func _on_player_set():
	target = GameManager.player
