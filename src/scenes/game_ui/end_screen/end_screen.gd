class_name EndScreen
extends Control

const ANIM_TIME = 0.3

var _tween: Tween

func _ready() -> void:
	hide_screen()

func animate_in() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	show()
	pivot_offset = size * 0.5
	size.y = 0
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "size.y", get_viewport_rect().size.y, ANIM_TIME)

func hide_screen() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	scale = Vector2.ONE
	hide()
