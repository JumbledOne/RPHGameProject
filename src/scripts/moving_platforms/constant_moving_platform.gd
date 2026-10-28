@tool
class_name ConstantMovingPlatform
extends BaseMovingPlatform

const DEFAULT_NOTIFIER_RECT := Rect2(-64.0, -16.0, 128.0, 32.0)

@export var direction: Vector2 = Vector2.RIGHT:
	set(value):
		direction = value.normalized()
@export var speed: float = 100.0
@export var notifier_rect: Rect2 = DEFAULT_NOTIFIER_RECT

var enabled: bool = false
var _visible_on_screen_notifier: VisibleOnScreenNotifier2D

func _ready() -> void:
	_visible_on_screen_notifier = VisibleOnScreenNotifier2D.new()
	_visible_on_screen_notifier.rect = notifier_rect
	add_child(_visible_on_screen_notifier)
	_visible_on_screen_notifier.screen_entered.connect(_on_screen_entered)

	if _visible_on_screen_notifier.is_on_screen():
		enable_movement()

func _physics_process(delta: float) -> void:
	if enabled:
		position += direction * speed * delta

func enable_movement() -> void:
	if enabled:
		return

	enabled = true
	if is_instance_valid(_visible_on_screen_notifier):
		_visible_on_screen_notifier.queue_free()
		_visible_on_screen_notifier = null

func _on_screen_entered() -> void:
	enable_movement()
