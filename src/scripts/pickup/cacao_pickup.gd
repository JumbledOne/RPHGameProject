extends Pickup

func _ready() -> void:
	LevelManager.register_collectible()
	super._ready()

func _apply_effect(_body: PlayerEntity) -> void:
	LevelManager.collect()

func _play_sound(sound: AudioStreamPlayer) -> void:
	preload("res://assets/audio/audio_resources/coin_effects.tres").play_random_at(sound)
	get_tree().create_timer(1.4).timeout.connect(sound.queue_free)
