extends Node

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

var is_paused: bool = false # We use this to ensure that the rest of the game still runs and only the game is actually paused
signal pause_toggled
var game_started: bool = false

func _ready() -> void:
	_update_cursor_state()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		toggle_pause()

func toggle_pause() -> void:
	is_paused = !is_paused
	_update_cursor_state()
	pause_toggled.emit()

func set_pause(v: bool):
	is_paused = v
	_update_cursor_state()
	pause_toggled.emit()

func _update_cursor_state() -> void:
	if game_started and not is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN  
	else: 
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# # # # # # # # # # # #
# Player data
var player_class: PlayerClass = UrbanCharacter.new()
var player: PlayerEntity:
	set(v):
		if player and v:
			push_error("Attempt to link player when one already exists")
			return
		# Unlink Previous
		if player:
			player.died.disconnect(_on_player_died)
		player = v
		# Link new
		if player:
			player.died.connect(_on_player_died)
		player_set.emit()
signal player_set

func _on_player_died():
	lives()

# # # # # # # # # # # #
# Game Flow
const LEVELS: Array[PackedScene] = [
	preload("res://scenes/levels/level_1_b.tscn"),
	preload("res://scenes/levels/level_2.tscn"),
	preload("res://scenes/levels/level_3.tscn"),
	preload("res://scenes/levels/level_4.tscn"),
	preload("res://scenes/levels/level_5.tscn"),
]
signal game_started_event
enum GameEnd { LOST, WON, OTHER }
signal game_ended(result: GameEnd)

var current_level: int = 0 # Used in GameScene to load the scene

const STARTING_LIVES: int = 3
var lives_left: int = STARTING_LIVES
signal lives_changed(lives: int)

func start_game(level: int, preserve_lives: bool = false):
	game_started = true
	_update_cursor_state()
	level_left_boundary = -INF
	level_right_boundary = INF
	if not preserve_lives:
		lives_left = STARTING_LIVES
		lives_changed.emit(lives_left)
	_reset_level_stats() # Reset before game_started signal since that creates the scene
	game_started_event.emit()
	current_level = level
	InterfaceManager.open_ui("GameUi")
	set_pause(false)
	
func lives() -> void:
	lives_left -= 1
	lives_changed.emit(lives_left)
	if lives_left > 0:
		InterfaceManager.do_on_transition(start_game.bind(current_level, true))
	else:
		game_end(GameEnd.LOST)

func game_end(result: GameEnd = GameEnd.OTHER) -> void:
	game_started = false
	_update_cursor_state()
	game_ended.emit(result)

func end_game(result: GameEnd = GameEnd.OTHER) -> void:
	game_end(result)
	
func get_level_scene() -> PackedScene:
	if current_level >= 0 and current_level < get_level_count():
		return LEVELS[current_level]
	return
	
func get_level_count() -> int:
	return len(LEVELS)

func return_to_main_menu():
	end_game()
	InterfaceManager.open_ui("MainMenu")

var level_left_boundary: float
var level_right_boundary: float

# # # # # # # # # # # #
# Level stats
var collected: int = 0
var total_collectibles: int = 0
var score: int = 0

const SCORE_PER_COLLECTIBLE: int = 100
const STAR_STEP: int = 5
const MAX_STARS: int = 3
const NEW_LIFE_THRESHOLD: int = 10

signal collectibles_changed(collected: int, total: int)
signal score_changed(score: int)

# Nothing calls this?
func register_collectible() -> void:
	total_collectibles += 1
	collectibles_changed.emit(collected, total_collectibles)
	
func collectibles_summary() -> String:
	return "%d/%d collected!" % [collected, total_collectibles]
	
func collect() -> void:
	collected += 1
	if collected % NEW_LIFE_THRESHOLD == 0:
		lives_left += 1
		lives_changed.emit(lives_left)
	activate_attack_buff()
	collectibles_changed.emit(collected, total_collectibles)
	add_score(SCORE_PER_COLLECTIBLE)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func get_stars() -> int:
	return mini(collected / STAR_STEP, MAX_STARS)

func _reset_level_stats():
	collected = 0
	total_collectibles = 0
	score = 0
	buff_end_msec = 0
	collectibles_changed.emit(collected, total_collectibles)
	score_changed.emit(score)

# # # # # # # # # # # #
# Attack buff
# Maybe remove these and make it a StatusEffect node under player?
const base_attack_duration: float = 0.75
const attackspeedpercollectible: float = 0.65
const maxattackspeed: int = 2
const BASE_ATTACK_DURATION: float = 0.75
const BUFF_DURATION: float = 3.0
const BUFF_ATTACK_SPEED: float = 1.5   # 1.5x speed while active

var buff_end_msec: int = 0

func activate_attack_buff() -> void:
	buff_end_msec = Time.get_ticks_msec() + int(BUFF_DURATION * 1000)

func is_buff_active() -> bool:
	return Time.get_ticks_msec() < buff_end_msec

func get_attack_speed() -> float:
	return BUFF_ATTACK_SPEED if is_buff_active() else 1.0
