extends Node2D

func _ready() -> void:
	ScenePlacer.register_level_layers(
			$BackgroundEffects/BackPixelLayer, 
			$LevelObjects, 
			$FrontPixelLayer
	)
