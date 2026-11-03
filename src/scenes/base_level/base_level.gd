extends Node2D

@export var time_limit: float = 180.0
@export var require_boss_to_finish := false
@export var use_custom_bounds := false
@export var level_bounds := Vector2(0, 2560)
@export var player_death_altitude := 128.0

func _ready() -> void:
	LevelManager.configure_level(time_limit, require_boss_to_finish, use_custom_bounds, level_bounds, player_death_altitude)
	ScenePlacer.register_level_layers(
			$BackgroundEffects/BackPixelLayer, 
			$FrontPixelLayer,
			$LevelObjects
	)
	LevelManager.preview_level.call_deferred(self)
