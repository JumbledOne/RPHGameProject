class_name EndScreen
extends Control

const ANIM_TIME = 0.3

var _tween: Tween
var _expanded_position: Vector2
var _expanded_size: Vector2

func _ready() -> void:
	_expanded_position = position
	_expanded_size = size
	hide_screen()

func animate_in() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	size = Vector2(_expanded_size.x, 0.0)
	position = Vector2(_expanded_position.x, get_viewport_rect().size.y * 0.5)
	show()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "size:y", _expanded_size.y, ANIM_TIME)
	_tween.parallel().tween_property(self, "position:y", _expanded_position.y, ANIM_TIME)

func hide_screen() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	position = _expanded_position
	size = _expanded_size
	hide()
