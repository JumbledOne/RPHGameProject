class_name EagleEffect
extends StatusEffect
## Adds one burst of lift to the next jump, then consumes itself.

var _platformer: PlatformerEntity

func apply() -> void:
	_platformer = entity as PlatformerEntity
	if _platformer == null:
		finish()
		return
	_platformer.jumped.connect(_on_jumped)

func _on_jumped() -> void:
	if not is_instance_valid(_platformer):
		finish()
		return
	_platformer.velocity.y -= _platformer.jump_velocity * 0.35
	finish()

func remove() -> void:
	if is_instance_valid(_platformer) and _platformer.jumped.is_connected(_on_jumped):
		_platformer.jumped.disconnect(_on_jumped)

func get_effect_duration() -> float:
	return -1.0

func tick() -> void:
	pass
