extends Node

signal hearts_changed(value)
signal cacao_changed(value)
signal score_changed(value)
signal powerup_changed(powerup_name, duration)
signal player_died
signal level_won

const MAX_HEARTS: int = 3

var selected_level: int = 1
var selected_tribe: String = "urban"
var hearts: int = MAX_HEARTS
var cacao: int = 0
var score: int = 0

# # # # # # # # # # # #
# Might remove the health functions since these these don't do anything?
# In fact they shouldn't do anything you should call the player directly through GameManager
func damage(amount: int = 1) -> void:
	hearts = max(hearts - amount, 0)
	hearts_changed.emit(hearts)
	if hearts == 0:
		player_died.emit()

func heal(amount: int = 1) -> void:
	hearts = min(hearts + amount, MAX_HEARTS)
	hearts_changed.emit(hearts)

func add_cacao(amount: int = 1) -> void:
	cacao += amount
	cacao_changed.emit(cacao)
	add_score(100 * amount)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func get_stars() -> int:
	if cacao >= 15: return 3
	if cacao >= 10: return 2
	if cacao >= 5: return 1
	return 0

# # # # # # # # # # # #
# Level controls
func reset_run() -> void:
	hearts = MAX_HEARTS
	cacao = 0
	score = 0
	hearts_changed.emit(hearts)
	cacao_changed.emit(cacao)
	score_changed.emit(score)
	
func start_level(level: int) -> void:
	selected_level = level
	reset_run()
	get_tree().paused = false
	#get_tree().change_scene_to_file(LEVELS[level]["scene"])

func restart_level() -> void:
	start_level(selected_level)

# # # # # # # # # # # #
# Scene switching
func go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
