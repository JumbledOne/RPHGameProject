extends Pickup

func _apply_effect(body: PlayerEntity) -> void:
	body.heal(2)
