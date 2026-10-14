extends Node

# Player data
var player: PlayerEntity:
	set(v):
		player = v
		player_set.emit()
signal player_set
