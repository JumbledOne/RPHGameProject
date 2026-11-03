extends Pickup

func _process(delta: float) -> void:
	super._process(delta)
	if sprite:
		sprite.region_rect.position.x = int(age * 6) % 2 * 32

func _apply_effect(body: PlayerEntity) -> void:
	body.add_status_effect(preload("res://status_effects/jump_boost.gd").new())
