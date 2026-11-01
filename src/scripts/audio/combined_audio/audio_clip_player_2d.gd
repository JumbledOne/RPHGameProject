class_name AudioClipPlayer2D
extends AudioStreamPlayer2D

var _play_generation: int = 0


func play_clip(start_time: String, end_time: String) -> void:
	if stream == null:
		return

	var start_seconds := CombinedAudio.parse_time(start_time)
	var end_seconds := CombinedAudio.parse_time(end_time)
	if start_seconds < 0.0 or end_seconds < 0.0:
		push_error("AudioClipPlayer2D.play_clip received an invalid time. Use seconds:centiseconds or minutes:seconds:centiseconds.")
		return
	if end_seconds <= start_seconds:
		push_error("AudioClipPlayer2D.play_clip end_time must be after start_time.")
		return
	if start_seconds > stream.get_length() or end_seconds > stream.get_length():
		push_error("AudioClipPlayer2D.play_clip range exceeds the audio stream duration (%.3f seconds)." % stream.get_length())
		return

	_play_generation += 1
	var generation := _play_generation
	super.play(start_seconds)
	await get_tree().create_timer(end_seconds - start_seconds).timeout
	if is_instance_valid(self) and generation == _play_generation:
		stop()
