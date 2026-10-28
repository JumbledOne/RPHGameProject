class_name StoryLabel
extends Label

const ANIM_TIME: float = 2.0
const NOTIFIER_MARGIN: float = 32.0

var _visible_on_screen_notifier: VisibleOnScreenNotifier2D
var _tween: Tween

func _ready() -> void:
	_visible_on_screen_notifier = VisibleOnScreenNotifier2D.new()
	_visible_on_screen_notifier.rect = Rect2(
		Vector2(NOTIFIER_MARGIN, 0.0),
		Vector2(maxf(size.x - NOTIFIER_MARGIN * 2.0, 0.0), size.y)
	)
	add_child(_visible_on_screen_notifier)
	_visible_on_screen_notifier.screen_entered.connect(_on_screen_entered)

	if _visible_on_screen_notifier.is_on_screen():
		_animate_visible_ratio()

func _on_screen_entered() -> void:
	_animate_visible_ratio()

func _animate_visible_ratio() -> void:
	if _tween:
		_tween.kill()

	visible_ratio = 0.0
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "visible_ratio", 1.0, ANIM_TIME)
