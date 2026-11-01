extends Node

const MAX_LEVEL_TIME: float = 120.0
const LEVEL_INFO_PATH: String = "res://assets/data/level_info.json"
const LEVELS: Array[PackedScene] = [
	preload("res://scenes/levels/level_1_b.tscn"),
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

var selected_level: int = 0
var current_level: int = 0
var game_started: bool = false
var lives_left: int = STARTING_LIVES
var level_left_boundary: float = -INF
var level_right_boundary: float = INF

var collected: int = 0
var cacao: int = 0
var total_collectibles: int = 0
var score: int = 0
var buff_end_msec: int = 0

func start_game(level: int, preserve_lives: bool = false) -> void:
	current_level = clampi(level, 0, get_level_count() - 1)
	selected_level = current_level
	game_started = true
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
	lives_left -= 1
	lives_changed.emit(lives_left)
	if lives_left > 0:
		InterfaceManager.do_on_transition(start_game.bind(current_level, true))
	else:
		game_end(GameEnd.LOST)

func game_end(result: GameEnd = GameEnd.OTHER) -> void:
	game_started = false
	game_ended.emit(result)
	if result == GameEnd.WON:
		level_won.emit()

func get_level_scene() -> PackedScene:
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
	game_end()
	InterfaceManager.open_ui("MainMenu")

func register_collectible() -> void:
	total_collectibles += 1
	collectibles_changed.emit(collected, total_collectibles)

func collectibles_summary() -> String:
	return "%d/%d collected!" % [collected, total_collectibles]

func collect() -> void:
	collected += 1
	cacao = collected
	if collected % NEW_LIFE_THRESHOLD == 0:
		lives_left += 1
		lives_changed.emit(lives_left)
	activate_attack_buff()
	collectibles_changed.emit(collected, total_collectibles)
	cacao_changed.emit(cacao)
	add_score(SCORE_PER_COLLECTIBLE)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func get_stars() -> int:
	return mini(collected / STAR_STEP, MAX_STARS)

func add_cacao(amount: int = 1) -> void:
	for _i in range(maxi(amount, 0)):
		collect()

func _reset_level_stats() -> void:
	collected = 0
	cacao = 0
	total_collectibles = 0
	score = 0
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
