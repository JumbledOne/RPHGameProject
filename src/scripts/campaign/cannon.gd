extends Node2D
@export var projectile_scene: PackedScene
@export var fire_interval: float = 2.8
@export var activation_range: float = 600.0
@export_enum("Left:-1", "Right:1") var direction: int = -1
var clock := 0.0
func _physics_process(delta: float) -> void:
	if not LevelManager.game_started or not is_instance_valid(GameManager.player):
		return
	if absf(GameManager.player.global_position.x - global_position.x) > activation_range:
		return
	clock += delta
	if clock >= fire_interval:
		clock = 0
		var features := get_tree().get_first_node_in_group("level_features")
		if features:
			features.fire_projectile(projectile_scene, global_position + Vector2(direction * 36, -10), direction)
