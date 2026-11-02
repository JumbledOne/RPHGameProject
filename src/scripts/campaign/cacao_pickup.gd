extends CampaignPickup

func _on_spawned() -> void:
	LevelManager.register_collectible()

func _apply_to_player(_player: PlayerEntity) -> void:
	LevelManager.collect()

func _play_collect_sound() -> void:
	var sound := AudioStreamPlayer.new()
	sound.volume_db = -12.0
	get_parent().add_child(sound)
	preload("res://assets/audio/audio_resources/coin_effects.tres").play_random_at(sound)
	get_tree().create_timer(1.4).timeout.connect(sound.queue_free)
