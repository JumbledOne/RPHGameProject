extends Node

const MAX_LEVEL_TIME: float = 180.0
const LEVEL_INFO_PATH: String = "res://assets/data/level_info.json"
const LEVELS: Array[PackedScene] = [
	preload("res://scenes/levels/level_1.tscn"),
	preload("res://scenes/levels/level_2.tscn"),
	preload("res://scenes/levels/level_3.tscn"),
	preload("res://scenes/levels/level_4.tscn"),
	preload("res://scenes/levels/level_5.tscn"),
]

signal game_started_event
signal game_ended(result: GameEnd)
signal level_won
signal lives_changed(lives: int)
signal collectibles_changed(collected: int, total: int)
signal cacao_changed(cacao: int)
signal score_changed(score: int)

enum GameEnd { LOST, WON, OTHER }

const STARTING_LIVES: int = 3
const SCORE_PER_COLLECTIBLE: int = 100
const STAR_STEP: int = 5
const MAX_STARS: int = 3
const NEW_LIFE_THRESHOLD: int = 10
const BASE_ATTACK_DURATION: float = 0.75
const BUFF_DURATION: float = 3.0
const BUFF_ATTACK_SPEED: float = 1.5
const DEATH_RESET_DELAY: float = 2.0

var selected_level: int = 0
var current_level: int = 0
var last_level_won: int = -1
var game_started: bool = false
var lives_left: int = STARTING_LIVES
var level_left_boundary: float = -INF
var level_right_boundary: float = INF

var collected: int = 0
var cacao: int = 0
var total_collectibles: int = 0
var score: int = 0
var score_multiplier: int = 1
var buff_end_msec: int = 0
var boss_defeated := false
var preview_scene_path: String = ""
var time_limit: float = MAX_LEVEL_TIME
var elapsed := 0.0
var require_boss_to_finish := false
var player_death_altitude := 128.0
var _death_reset_id: int = 0

func _physics_process(delta: float) -> void:
	if game_started and not GameManager.is_paused:
		elapsed += delta
		if time_limit > 0 and elapsed >= time_limit and is_instance_valid(GameManager.player):
			GameManager.player.die()

func configure_level(limit: float, require_boss: bool, bounds_enabled: bool, bounds: Vector2, death_altitude: float) -> void:
	time_limit = limit
	require_boss_to_finish = require_boss
	player_death_altitude = death_altitude
	if bounds_enabled:
		level_left_boundary = bounds.x
		level_right_boundary = bounds.y
	if is_instance_valid(GameManager.player):
		GameManager.player.death_altitude = death_altitude

func get_time_left() -> float:
	return maxf(time_limit - elapsed, 0.0)

func finish_level() -> bool:
	if require_boss_to_finish and not boss_defeated:
		return false
	if game_started:
		game_end.call_deferred(GameEnd.WON)
	return true

func preview_level(scene: Node2D) -> void:
	if get_tree().current_scene == scene and not scene.scene_file_path.is_empty():
		preview_scene_path = scene.scene_file_path
		GameManager.player = null
		get_tree().change_scene_to_file.call_deferred("res://scenes/game_scene/game_scene.tscn")

func start_game(level: int, preserve_lives: bool = false) -> void:
	_death_reset_id += 1
	current_level = clampi(level, 0, get_level_count() - 1)
	selected_level = current_level
	game_started = true
	elapsed = 0.0
	time_limit = MAX_LEVEL_TIME
	level_left_boundary = -INF
	level_right_boundary = INF
	if not preserve_lives:
		lives_left = STARTING_LIVES
		lives_changed.emit(lives_left)
	_reset_level_stats()
	game_started_event.emit()
	InterfaceManager.open_ui("GameUi")
	GameManager.set_pause(false)

func lose_life() -> void:
	if not game_started:
		return
	game_started = false
	Audio.music.stop()
	lives_left -= 1
	lives_changed.emit(lives_left)
	_death_reset_id += 1
	var reset_id := _death_reset_id
	await get_tree().create_timer(DEATH_RESET_DELAY).timeout
	if reset_id != _death_reset_id:
		return
	if lives_left > 0:
		InterfaceManager.do_on_transition(start_game.bind(current_level, true))
	else:
		game_end(GameEnd.LOST)

func game_end(result: GameEnd = GameEnd.OTHER) -> void:
	_death_reset_id += 1
	game_started = false
	GameManager.set_pause(false)
	game_ended.emit(result)
	if result == GameEnd.WON:
		last_level_won = current_level
		level_won.emit()

func get_level_scene() -> PackedScene:
	if not preview_scene_path.is_empty():
		return load(preview_scene_path)
	if current_level >= 0 and current_level < get_level_count():
		return LEVELS[current_level]
	return null

func get_level_count() -> int:
	return LEVELS.size()

func get_level_info(level: int) -> Dictionary:
	var data: Variant = FileUtils.load_json(LEVEL_INFO_PATH)
	if data is Dictionary and data.get("levels") is Array and level >= 0 and level < data.levels.size():
		return data.levels[level]
	return {}

func start_level(level: int) -> void:
	start_game(level)

func restart_level() -> void:
	start_game(current_level)

func return_to_main_menu() -> void:
	preview_scene_path = ""
	get_tree().paused = false
	game_end()
	var level_root := get_tree().get_first_node_in_group("level_root")
	if is_instance_valid(level_root):
		level_root.clear_level()
	Audio.reset_music()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	InterfaceManager.open_ui("MainMenu")
	var other_selectors := get_tree().get_first_node_in_group("other_selectors")
	if other_selectors:
		other_selectors.call("show_immediately")

func register_collectible() -> void:
	total_collectibles += 1
	collectibles_changed.emit(collected, total_collectibles)

func collectibles_summary() -> String:
	return "%d/%d collected!" % [collected, total_collectibles]

func collect() -> void:
	collected += 1
	cacao = collected
	score_multiplier = 1 + collected / STAR_STEP
	if collected % NEW_LIFE_THRESHOLD == 0:
		lives_left += 1
		lives_changed.emit(lives_left)
	collectibles_changed.emit(collected, total_collectibles)
	cacao_changed.emit(cacao)
	add_score(SCORE_PER_COLLECTIBLE)

func add_score(amount: int) -> void:
	score += amount * score_multiplier
	score_changed.emit(score)

func get_stars() -> int:
	var stars: int = mini(collected / STAR_STEP, 2)
	if collected == total_collectibles and total_collectibles >= 15 and boss_defeated:
		stars = 3
	return stars

func add_cacao(amount: int = 1) -> void:
	for _i in range(maxi(amount, 0)):
		collect()

func _reset_level_stats() -> void:
	require_boss_to_finish = false
	boss_defeated = false
	collected = 0
	cacao = 0
	total_collectibles = 0
	score = 0
	score_multiplier = 1
	buff_end_msec = 0
	collectibles_changed.emit(collected, total_collectibles)
	cacao_changed.emit(cacao)
	score_changed.emit(score)

func activate_attack_buff() -> void:
	buff_end_msec = Time.get_ticks_msec() + int(BUFF_DURATION * 1000.0)

func is_buff_active() -> bool:
	return Time.get_ticks_msec() < buff_end_msec

func get_attack_speed() -> float:
	return BUFF_ATTACK_SPEED if is_buff_active() else 1.0
