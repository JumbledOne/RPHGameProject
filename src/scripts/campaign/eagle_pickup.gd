extends CampaignPickup

const EAGLE_EFFECT = preload("res://status_effects/eagle.gd")

func _apply_to_player(player: PlayerEntity) -> void:
	player.add_status_effect(EAGLE_EFFECT.new())

func _animate_sprite() -> void:
	sprite.region_rect.position.x = int(age * 6.0) % 2 * 32
