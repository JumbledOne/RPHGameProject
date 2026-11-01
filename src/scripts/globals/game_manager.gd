extends Node

signal hearts_changed(value: int)
signal cacao_changed(value: int)
signal powerup_changed(powerup_name: String, duration: float)
signal player_died
signal level_won

const MAX_LEVEL_TIME: float = 120 # In seconds

const MAX_HEARTS: int = 3
const LEVEL_INFO_PATH: String = "res://assets/data/level_info.json"
var selected_level: int = 0
var selected_tribe: String = "urban"
var hearts: int = MAX_HEARTS
var cacao: int = 0

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
		if is_instance_valid(player) and is_instance_valid(v):
			push_error("Attempt to link player when one already exists")
			return
		# Unlink Previous
		if is_instance_valid(player):
			player.died.disconnect(_on_player_died)
			player.damaged.disconnect(_on_player_health_changed)
			player.healed.disconnect(_on_player_health_changed)
		player = v
		# Link new
		if is_instance_valid(player):
			player.died.connect(_on_player_died)
			player.damaged.connect(_on_player_health_changed)
			player.healed.connect(_on_player_health_changed)
			_on_player_health_changed()
		player_set.emit()
signal player_set

func _on_player_died():
	player_died.emit()
	lives()

func _on_player_health_changed() -> void:
	if is_instance_valid(player):
		hearts = player.health
		hearts_changed.emit(hearts)

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
	current_level = clampi(level, 0, get_level_count() - 1)
	selected_level = current_level
	game_started = true
	_update_cursor_state()
	level_left_boundary = -INF
	level_right_boundary = INF
	if not preserve_lives:
		lives_left = STARTING_LIVES
		lives_changed.emit(lives_left)
	_reset_level_stats() # Reset before game_started signal since that creates the scene
	if not preserve_lives:
		hearts = MAX_HEARTS
		hearts_changed.emit(hearts)
	game_started_event.emit()
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
	if result == GameEnd.WON:
		level_won.emit()

func end_game(result: GameEnd = GameEnd.OTHER) -> void:
	game_end(result)
	
func get_level_scene() -> PackedScene:
	if current_level >= 0 and current_level < get_level_count():
		return LEVELS[current_level]
	return
	
func get_level_count() -> int:
	return len(LEVELS)

func get_level_info(level: int) -> Dictionary:
	var data: Variant = FileUtils.load_json(LEVEL_INFO_PATH)
	if data is Dictionary and data.get("levels") is Array and level >= 0 and level < data.levels.size():
		return data.levels[level]
	return {}

func start_level(level: int) -> void:
	start_game(level)

func restart_level() -> void:
	start_game(current_level)

func return_to_main_menu():
	end_game()
	InterfaceManager.open_ui("MainMenu")

func go_to_menu() -> void:
	return_to_main_menu()

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
	cacao = collected
	cacao_changed.emit(cacao)
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

func add_cacao(amount: int = 1) -> void:
	for _i in range(maxi(amount, 0)):
		collect()

func damage(amount: int = 1) -> void:
	if is_instance_valid(player):
		player.hurt(amount)
	else:
		hearts = maxi(hearts - amount, 0)
		hearts_changed.emit(hearts)
		if hearts == 0:
			player_died.emit()

func heal(amount: int = 1) -> void:
	if is_instance_valid(player):
		player.heal(amount)
	else:
		hearts = mini(hearts + amount, MAX_HEARTS)
		hearts_changed.emit(hearts)

func _reset_level_stats():
	collected = 0
	cacao = 0
	total_collectibles = 0
	score = 0
	buff_end_msec = 0
	collectibles_changed.emit(collected, total_collectibles)
	cacao_changed.emit(cacao)
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
