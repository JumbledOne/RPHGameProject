@abstract
class_name StatusEffect
extends Node
## Attach effects through Entity.add_status_effect(). Duplicate types refresh.
var entity: Entity
var _tick_time: float = 0.0
var _time: float = 0.0
var _applied: bool = false

func _ready() -> void:
	entity = get_parent() as Entity
	if entity == null:
		push_error("StatusEffect must be a child of an Entity.")
		queue_free()
		return
	if not entity._register_status_effect(self):
		queue_free()
		return
	start_effect_timer()
	_applied = true
	apply()
	if not _applied:
		return
	entity.status_effect_added.emit(self)
	var audio := get_apply_audio()
	if audio != null:
		var player := AudioStreamPlayer2D.new()
		player.stream = audio
		player.finished.connect(player.queue_free)
		entity.add_child(player)
		player.play()

func _physics_process(delta: float) -> void:
	if not _applied:
		return
	var duration := get_effect_duration()
	var active_delta := delta if duration < 0 else minf(delta, maxf(duration - _time, 0))
	_time += active_delta
	_tick_time += active_delta
	while _tick_time >= 1.0 and _applied:
		_tick_time -= 1.0
		tick()
	if _applied and duration >= 0 and _time >= duration:
		finish()

func _exit_tree() -> void:
	_deactivate()

func start_effect_timer() -> void:
	_time = 0.0
	_tick_time = 0.0

func refresh_from(_other: StatusEffect) -> void:
	start_effect_timer()

func get_remaining_time() -> float:
	return INF if get_effect_duration() < 0 else maxf(get_effect_duration() - _time, 0)

func get_effect_key() -> StringName:
	return StringName(get_script().resource_path)

func get_apply_audio() -> AudioStream:
	return null

func finish() -> void:
	_deactivate()
	queue_free()

func _deactivate() -> void:
	if not _applied:
		return
	_applied = false
	remove()
	if is_instance_valid(entity):
		entity._unregister_status_effect(self)

@abstract func apply()
@abstract func remove()
@abstract func get_effect_duration() -> float
@abstract func tick()
