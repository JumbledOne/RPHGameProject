class_name BlindnessEffect
extends StatusEffect

@export var duration: float = 3.0
var _sources: Array[WeakRef] = []
var _requires_source := false

func add_source(source: Node) -> void:
	_requires_source = true
	for reference in _sources:
		if reference.get_ref() == source:
			return
	_sources.append(weakref(source))

func remove_source(source: Node) -> void:
	for reference in _sources.duplicate():
		if reference.get_ref() == source or not is_instance_valid(reference.get_ref()):
			_sources.erase(reference)
	if _requires_source and _sources.is_empty():
		finish()

func refresh_from(other: StatusEffect) -> void:
	super(other)
	var blindness := other as BlindnessEffect
	if blindness != null:
		duration = blindness.duration
		for reference in blindness._sources:
			if is_instance_valid(reference.get_ref()):
				add_source(reference.get_ref())

func _physics_process(delta: float) -> void:
	for reference in _sources.duplicate():
		var source: Node = reference.get_ref()
		if not is_instance_valid(source) or source.is_queued_for_deletion():
			_sources.erase(reference)
	if _requires_source and _sources.is_empty():
		finish()
		return
	super(delta)

func apply() -> void:
	pass

func remove() -> void:
	pass

func get_effect_duration() -> float:
	return duration

func tick() -> void:
	pass
