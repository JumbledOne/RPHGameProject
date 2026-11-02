class_name SquareThrowAbility
extends PlayerAbility

const THROW_SPEED: float = 220.0
const THROW_DISTANCE: float = 176.0

func do(doer: PlayerEntity) -> void:
	if not is_instance_valid(doer):
		return
	var scene_root: Node = doer.get_tree().current_scene
	if scene_root == null:
		return

	var square := Node2D.new()
	square.name = "AbilitySquare"
	square.set_script(preload("res://entities/player/player_abilities/ability_square_visual.gd"))
	scene_root.add_child(square)
	square.global_position = doer.global_position + Vector2(0.0, -8.0)
	var direction: float = signf(doer.horizontal_movement)
	if is_zero_approx(direction):
		direction = 1.0 if doer.velocity.x >= 0.0 else -1.0

	var tween: Tween = square.create_tween()
	tween.tween_property(square, "position:x", square.position.x + direction * THROW_DISTANCE, THROW_DISTANCE / THROW_SPEED)
	tween.tween_callback(square.queue_free)
