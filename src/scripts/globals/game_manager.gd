extends Node

# Player data
var player: PlayerEntity:
	set(v):
		player = v
		player_set.emit()
signal player_set

# Collectibles
signal collectibles_changed(collected: int, total: int)
var collected := 0
var total := 0
func reset_collectibles() -> void:
	collected = 0
	total = 0
	collectibles_changed.emit(collected, total)
func register_collectible() -> void:
	total += 1
	collectibles_changed.emit(collected, total)
func collect() -> void:
	collected += 1
	collectibles_changed.emit(collected, total)
func collectibles_summary() -> String:
	return "%d/%d collected!" % [collected, total]
