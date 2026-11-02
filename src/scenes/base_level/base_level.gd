extends LevelFeatures

func _ready() -> void:
	super()
	ScenePlacer.register_level_layers(
			$BackgroundEffects/BackPixelLayer, 
			$FrontPixelLayer,
			$LevelObjects
	)
