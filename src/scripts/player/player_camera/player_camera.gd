extends Camera2D

@export var target: Node2D
@export var dead_zone_right: float = 16 # In px
@export var dead_zone_left: float = -32 # In px

func _ready() -> void:
	GameManager.player_set.connect(_on_player_set)

func _physics_process(_delta: float) -> void:
	if not target:
		return
	var x_diff: float = target.global_position.x - global_position.x
	if x_diff > dead_zone_right:
		position.x = floor(target.global_position.x - dead_zone_right)
	elif x_diff < dead_zone_left:
		position.x = floor(target.global_position.x - dead_zone_left)

func _on_player_set():
	target = GameManager.player
