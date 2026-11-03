class_name Weapon
extends Node2D

@export var projectile_scene: PackedScene
@export var friendly := false

func fire(direction: float) -> Projectile:
	if projectile_scene == null:
		return null
	var shot := projectile_scene.instantiate() as Projectile
	if shot == null:
		push_error("Weapon projectile scene must have a Projectile root")
		return null
	shot.launch(direction, friendly)
	var level_objects := ScenePlacer.level_objects
	if not is_instance_valid(level_objects):
		shot.free()
		return null
	level_objects.add_child(shot)
	shot.global_position = get_parent().global_position + Vector2(direction * absf(position.x), position.y)
	return shot
