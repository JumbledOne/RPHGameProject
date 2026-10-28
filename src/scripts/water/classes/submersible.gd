class_name Submersible
extends Node
# Add as a child of anything that can be submerged
# Water finds this node by its name and calls enter_water and exit_water
# Listen to the signals to react to water

signal water_entered
signal water_exited

# Number of water bodies currently overlapping
# So that leaving one body of water while in another doesn't count as exiting
var _water_count: int = 0

func _ready() -> void:
	name = &"Submersible"

func enter_water() -> void:
	_water_count += 1
	if _water_count == 1:
		water_entered.emit()

func exit_water() -> void:
	if _water_count == 0:
		return
	_water_count -= 1
	if _water_count == 0:
		water_exited.emit()

func is_in_water() -> bool:
	return _water_count > 0
