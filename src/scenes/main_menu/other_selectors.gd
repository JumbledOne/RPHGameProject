extends Control

const FADE_TIME: float = 0.5

var _fade_tween: Tween

func fade_out() -> void:
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	visible = true
	_fade_tween = create_tween()
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	await _fade_tween.finished
	visible = false

func show_immediately() -> void:
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	modulate.a = 1.0
	visible = true
