class_name LevelFeatures
extends Node2D
## Shared run services only. This script never places terrain, enemies or pickups.
@export var time_limit: float = 180.0
@export var require_boss_to_finish: bool = false
@export var use_custom_bounds: bool = false
@export var level_bounds := Vector2(0, 2560)
@export var player_death_altitude: float = 128.0
const PROJECTILE = preload("res://scripts/campaign/campaign_projectile.gd")
const ATLAS = preload("res://assets/gfx/sprites/tilemap-updated.png")
var objects: Node2D
var elapsed := 0.0
var blind_requested := false

func _ready() -> void:
	add_to_group("level_features")
	objects = get_node_or_null("LevelObjects")
	if objects == null:
		objects = Node2D.new()
		objects.name = "LevelObjects"
		add_child(objects)
	if use_custom_bounds:
		LevelManager.level_left_boundary = level_bounds.x
		LevelManager.level_right_boundary = level_bounds.y
	ScenePlacer.register_level_layers(objects, objects, objects)
	_prepare_playtest.call_deferred()

func _prepare_playtest() -> void:
	if is_instance_valid(GameManager.player):
		GameManager.player.death_altitude = player_death_altitude
	# F6 wraps this exact authored scene in the normal HUD/retry/transition shell.
	if get_tree().current_scene == self and not scene_file_path.is_empty():
		LevelManager.preview_scene_path = scene_file_path
		GameManager.player = null
		get_tree().change_scene_to_file.call_deferred("res://scenes/game_scene/game_scene.tscn")

func _physics_process(delta: float) -> void:
	if LevelManager.game_started and not GameManager.is_paused:
		elapsed += delta
		blind_requested = false
		if time_limit > 0 and elapsed >= time_limit and is_instance_valid(GameManager.player):
			GameManager.player.die()

func finish_level() -> bool:
	if require_boss_to_finish and not LevelManager.boss_defeated:
		return false
	if LevelManager.game_started:
		LevelManager.game_end.call_deferred(LevelManager.GameEnd.WON)
	return true

func fire_projectile(at: Vector2, direction: float, kind: String, friendly: bool = false) -> Area2D:
	var projectile := Area2D.new()
	projectile.set_script(PROJECTILE)
	projectile.friendly = friendly
	projectile.velocity = Vector2(direction * (430 if friendly else 240), 0)
	var sprite := Sprite2D.new()
	if kind == "durian":
		sprite.texture = preload("res://assets/gfx/sprites/durian.png")
	elif kind == "american":
		sprite.texture = preload("res://assets/gfx/sprites/books2.png")
	elif kind == "japanese":
		sprite.texture = preload("res://assets/gfx/campaign/sushi.svg")
	else:
		sprite.texture = ATLAS
		sprite.region_enabled = true
		sprite.region_rect = Rect2(104, 304, 16, 16)
	projectile.sprite = sprite
	projectile.add_child(sprite)
	objects.add_child(projectile)
	projectile.global_position = at
	return projectile
