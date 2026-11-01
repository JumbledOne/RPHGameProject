class_name CombinedAudioPlayer2D
extends AudioStreamPlayer2D

@export var combined_audio: CombinedAudio

func play_audio() -> void:
	if combined_audio != null:
		combined_audio.play_random_at(self)
	elif stream != null:
		super.play()


func play_stream_from(from_position: float) -> void:
	super.play(from_position)
