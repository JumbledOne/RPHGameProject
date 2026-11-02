class_name MovingPlatform
extends AnimatableBody2D
## Physics-synchronized motion carries CharacterBody2D passengers.
## The destination is relative to the position placed in the level.

@export var travel_offset: Vector2 = Vector2(128, 0)
@export_range(0.1, 30.0) var travel_time: float = 3.0
@export var moving: bool = true
@export var start_on_screen: bool = false

var _origin: Vector2
var _elapsed: float = 0.0
var _started: bool = true

func _ready() -> void:
	_origin = position
	_started = not start_on_screen
	if start_on_screen:
		var notifier := VisibleOnScreenNotifier2D.new()
		notifier.rect = Rect2(-128, -64, 256, 128)
		add_child(notifier)
		notifier.screen_entered.connect(func(): _started = true)

func _physics_process(delta: float) -> void:
	if not moving or not _started:
		return
	_elapsed += delta
	position = _origin + _motion_offset()

func _motion_offset() -> Vector2:
	var progress := fposmod(_elapsed / maxf(travel_time, 0.1), 2.0)
	return travel_offset * (progress if progress <= 1.0 else 2.0 - progress)
