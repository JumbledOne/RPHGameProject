extends CampaignPickup

func _apply_to_player(player: PlayerEntity) -> void:
	player.durians += 1
