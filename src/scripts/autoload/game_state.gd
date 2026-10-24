extends Node

signal hearts_changed(value)
signal cacao_changed(value)
signal score_changed(value)
signal powerup_changed(powerup_name, duration)
signal player_died
signal level_won

const MAX_HEARTS := 3

var selected_level := 1
var selected_tribe := "urban"
var hearts := MAX_HEARTS
var cacao := 0
var score := 0

# Dates/descriptions are PLACEHOLDERS mf. Replace with the other guys' researched text.
const LEVELS := {
	1: {"date": "1700s", "title": "Pre-Colonial Davao",
		"desc": "Indigenous tribes live and trade along the Davao Gulf.",
		"scene": "res://scenes/levels/level_1.tscn"},
	2: {"date": "1800s", "title": "Spaniards Conquered Davao",
		"desc": "Spanish colonizers arrive and take control of the region.",
		"scene": "res://scenes/levels/level_2.tscn"},
	3: {"date": "1900s", "title": "Arrival of the Japanese",
		"desc": "Japanese settlers arrive and Davao City is established.",
		"scene": "res://scenes/levels/level_3.tscn"},
	4: {"date": "1940s", "title": "World War II",
		"desc": "Davao during the war years.",
		"scene": "res://scenes/levels/level_4.tscn"},
	5: {"date": "Today", "title": "Davao Today",
		"desc": "Modern Davao, the city we know now.",
		"scene": "res://scenes/levels/level_5.tscn"},
}

func reset_run() -> void:
	hearts = MAX_HEARTS
	cacao = 0
	score = 0
	hearts_changed.emit(hearts)
	cacao_changed.emit(cacao)
	score_changed.emit(score)

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

func start_level(level: int) -> void:
	selected_level = level
	reset_run()
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVELS[level]["scene"])

func restart_level() -> void:
	start_level(selected_level)

func go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
