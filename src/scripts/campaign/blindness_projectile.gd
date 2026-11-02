extends CampaignProjectile

func _apply_hit_effect(body: Node2D) -> void:
	if body is Entity:
		body.add_status_effect(BlindnessEffect.new())
