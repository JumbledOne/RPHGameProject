class_name JumpBoostEffect
extends StatusEffect
## Adds one burst of lift to the next jump, then consumes itself.

const POWERED_JUMP_AUDIO := preload("res://assets/audio/sfx/powered_jump.wav")

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
	_play_powered_jump_audio()
	finish()

func _play_powered_jump_audio() -> void:
	var audio_player := AudioStreamPlayer2D.new()
	audio_player.stream = POWERED_JUMP_AUDIO
	audio_player.finished.connect(audio_player.queue_free)
	_platformer.add_child(audio_player)
	audio_player.play()

func remove() -> void:
	if is_instance_valid(_platformer) and _platformer.jumped.is_connected(_on_jumped):
		_platformer.jumped.disconnect(_on_jumped)

func get_effect_duration() -> float:
	return -1.0

func tick() -> void:
	pass
