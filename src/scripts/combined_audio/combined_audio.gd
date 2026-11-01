# CombinedAudio markers use M:SS:mmm, such as "0:02:180" for 2.18 seconds.
# An un-ranged marker ends at the next marker ("0:02:180", "0:04:150").
# An explicit marker like "0:02:180 -> 0:02:700" skips next-marker matching.
class_name CombinedAudio
extends Resource

@export var audio_stream: AudioStream
@export var clip_times: Array[String] = []

var _play_generations: Dictionary = {}


func play_random_at(audio_stream_player: Node) -> void:
	var clips := _get_clips()
	if clips.is_empty():
		return
	if not is_instance_valid(audio_stream_player):
		push_error("CombinedAudio.play_random_at requires a valid audio player.")
		return
	if not (audio_stream_player is AudioStreamPlayer or audio_stream_player is AudioStreamPlayer2D):
		push_error("CombinedAudio.play_random_at supports AudioStreamPlayer and AudioStreamPlayer2D.")
		return
	if audio_stream_player.get_tree() == null:
		push_error("CombinedAudio.play_random_at requires a player inside the scene tree.")
		return

	var clip: Vector2 = clips.pick_random()
	var start_seconds := clip.x
	var end_seconds := clip.y
	var player_id := audio_stream_player.get_instance_id()
	var generation: int = _play_generations.get(player_id, 0) + 1
	_play_generations[player_id] = generation

	# Both supported player types expose the same playback properties.
	audio_stream_player.set("stream", audio_stream)
	if audio_stream_player.has_method("play_stream_from"):
		audio_stream_player.call("play_stream_from", start_seconds)
	else:
		audio_stream_player.call("play", start_seconds)
	await audio_stream_player.get_tree().create_timer(end_seconds - start_seconds).timeout

	if not is_instance_valid(audio_stream_player):
		return
	if _play_generations.get(player_id) == generation:
		audio_stream_player.call("stop")
		_play_generations.erase(player_id)


func _get_clips() -> Array[Vector2]:
	var clips: Array[Vector2] = []
	if audio_stream == null:
		push_error("CombinedAudio has no audio_stream assigned.")
		return clips
	if clip_times.is_empty():
		push_error("CombinedAudio needs at least one clip time.")
		return clips

	var parsed_starts: Array[float] = []
	var parsed_ends: Array[float] = []	# -1 means infer the end from the next marker.
	for index in range(clip_times.size()):
		var parts := clip_times[index].split("->", false, 1)
		if parts.size() > 2:
			push_error("CombinedAudio clip_times[%d] has too many '->' separators." % index)
			return []
		var start := _parse_time(parts[0].strip_edges(), index)
		if start < 0.0:
			return []
		if start > audio_stream.get_length():
			push_error("CombinedAudio clip_times[%d] starts after the audio stream duration (%.3f seconds)." % [index, audio_stream.get_length()])
			return []
		parsed_starts.append(start)
		var end := -1.0
		if parts.size() == 2:
			end = _parse_time(parts[1].strip_edges(), index)
			if end < 0.0:
				return []
			if end <= start:
				push_error("CombinedAudio clip_times[%d] must end after it starts." % index)
				return []
		parsed_ends.append(end)

	for index in range(parsed_starts.size()):
		var start := parsed_starts[index]
		var end := parsed_ends[index]
		if end < 0.0:
			for next_index in range(index + 1, parsed_starts.size()):
				if parsed_starts[next_index] > start:
					end = parsed_starts[next_index]
					break
			if end < 0.0:
				continue # A final plain timestamp is a boundary, not a playable clip.
		if end > audio_stream.get_length():
			push_error("CombinedAudio clip_times[%d] ends after the audio stream duration." % index)
			return []
		clips.append(Vector2(start, end))
	return clips


func _parse_time(value: String, index: int) -> float:
	var parts := value.split(":", false, 2)
	if parts.size() != 3 or not parts[0].is_valid_int() or not parts[1].is_valid_int() or not parts[2].is_valid_int():
		push_error("CombinedAudio clip_times[%d] has invalid time '%s'. Use M:SS:mmm, such as 0:02:180." % [index, value])
		return -1.0
	var minutes := int(parts[0])
	var seconds := int(parts[1])
	var milliseconds := int(parts[2])
	if minutes < 0 or seconds < 0 or seconds >= 60 or milliseconds < 0 or milliseconds >= 1000:
		push_error("CombinedAudio clip_times[%d] has invalid time '%s'. Seconds must be 00-59 and milliseconds 000-999." % [index, value])
		return -1.0
	return float(minutes * 60 + seconds) + float(milliseconds) / 1000.0
