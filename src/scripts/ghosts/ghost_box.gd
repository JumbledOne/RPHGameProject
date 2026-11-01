extends Control

const MOVE_CHANCE: float = 0.3

@export var entities: int = 5
@export var ghost_scene: PackedScene = preload("res://scripts/ghosts/ghost.tscn")
@export_range(0.0, 0.5, 0.01) var floor_height_ratio: float = 0.3
@export var horizontal_margin: float = 16.0

var _ghosts: Array[Ghost] = []
var _visible_on_screen_notifier: VisibleOnScreenNotifier2D
var _time: float = 0.0

func _ready() -> void:
	_visible_on_screen_notifier = VisibleOnScreenNotifier2D.new()
	_visible_on_screen_notifier.rect = Rect2(Vector2.ZERO, size)
	add_child(_visible_on_screen_notifier)
	_visible_on_screen_notifier.screen_entered.connect(_set_ghosts_active.bind(true))
	_visible_on_screen_notifier.screen_exited.connect(_set_ghosts_active.bind(false))

	var floor_top := size.y * (1.0 - floor_height_ratio)
	var floor_bounds := Rect2(
		Vector2(horizontal_margin, floor_top),
		Vector2(maxf(size.x - horizontal_margin * 2.0, 0.0), maxf(size.y - floor_top, 0.0))
	)
	for index in range(maxi(entities, 0)):
		var ghost := ghost_scene.instantiate() as Ghost
		if ghost == null:
			push_error("GhostBox ghost_scene must instantiate a Ghost node.")
			break
		add_child(ghost)
		var start := Vector2(
			randf_range(floor_bounds.position.x, floor_bounds.end.x),
			floor_bounds.end.y
		)
		ghost.initialize(floor_bounds, start)
		_ghosts.append(ghost)

	_set_ghosts_active(_visible_on_screen_notifier.is_on_screen())

func _physics_process(delta: float) -> void:
	_time += delta
	if _time > 1.0:
		_time = 0.0
		_update()

func _update() -> void:
	for ghost in _ghosts:
		if randf() < MOVE_CHANCE:
			ghost.move_to_random_floor_position()

func _set_ghosts_active(active: bool) -> void:
	set_physics_process(active)
	for ghost in _ghosts:
		if not is_instance_valid(ghost):
			continue
		ghost.set_physics_process(active)
		if active:
			ghost.get_node("AnimationPlayer").play()
		elif ghost.get_node("AnimationPlayer").is_playing():
			ghost.get_node("AnimationPlayer").pause()
