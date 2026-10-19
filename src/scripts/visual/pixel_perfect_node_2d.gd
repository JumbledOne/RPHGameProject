class_name PixelPerfectNode2D
extends Node2D
# Snaps to pixel grid so that the pixel art is always consistent

func _ready() -> void:
	top_level = true
	
func _process(_delta: float) -> void:
	global_position = floor($"..".global_position)
