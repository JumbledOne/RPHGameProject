extends Node

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

# # # # # # # # # # # #
# Player data
var player: PlayerEntity:
	set(v):
		player = v
		player_set.emit()
signal player_set

# # # # # # # # # # # #
# Game Flow
const LEVELS: Array[PackedScene] = [
	preload("res://scenes/levels/level_1_b.tscn"),
	preload("res://scenes/levels/level_2.tscn"),
	preload("res://scenes/levels/level_3.tscn"),
	preload("res://scenes/levels/level_4.tscn"),
	preload("res://scenes/levels/level_5.tscn"),
]
signal game_started
signal game_ended
var current_level: int = 0 # Used in GameScene to load the scene
func start_game(level: int):
	level_left_boundary = -INF
	level_right_boundary = INF
	game_started.emit()
	current_level = level
	InterfaceManager.open_ui("GameUi")
	
func end_game():
	game_ended.emit()
	
func get_level_scene() -> PackedScene:
	if current_level >= 0 and current_level < get_level_count():
		return LEVELS[current_level]
	return
	
func get_level_count() -> int:
	return len(LEVELS)

var level_left_boundary: float
var level_right_boundary: float

# # # # # # # # # # # #
# Collectibles
signal collectibles_changed(collected: int, total: int)
var collected := 0
var total := 0

const base_attack_duration := 0.75
const attackspeedpercollectible := 0.65
const maxattackspeed := 2
const BASE_ATTACK_DURATION := 0.75
const BUFF_DURATION := 3.0
const BUFF_ATTACK_SPEED := 1.5   # 1.5x speed while active

var buff_end_msec := 0

func activate_attack_buff() -> void:
	buff_end_msec = Time.get_ticks_msec() + int(BUFF_DURATION * 1000)

func is_buff_active() -> bool:
	return Time.get_ticks_msec() < buff_end_msec

func get_attack_speed() -> float:
	return BUFF_ATTACK_SPEED if is_buff_active() else 1.0
	
func register_collectible() -> void:
	total += 1
	collectibles_changed.emit(collected, total)
	
func collectibles_summary() -> String:
	return "%d/%d collected!" % [collected, total]
	
func collect() -> void:
	collected += 1
	activate_attack_buff()
	collectibles_changed.emit(collected, total)

func reset_collectibles() -> void:
	collected = 0
	total = 0
	buff_end_msec = 0
	collectibles_changed.emit(collected, total)
