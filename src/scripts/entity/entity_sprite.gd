class_name EntitySprite
extends Node2D

const VANISH_CLOUD: PackedScene = preload("res://effects/vanish_cloud/vanish_cloud.tscn")
const DAMAGE_FLASH_DURATION: float = 0.12
const DEATH_POSE_DURATION: float = 1.0

@export var sprite_path: NodePath = ^"CharacterSprite"

var entity: Entity
var _color_tween: Tween
var _death_started := false

func _ready() -> void:
	entity = get_parent() as Entity
	if entity == null:
		return
	entity.damaged.connect(_on_damaged)
	entity.died.connect(_on_entity_died)

func _on_damaged() -> void:
	var visual := _get_color_target()
	if visual == null:
		return
	if _color_tween and _color_tween.is_running():
		_color_tween.kill()
	visual.modulate = Color.RED
	_color_tween = create_tween()
	_color_tween.tween_property(visual, "modulate", Color.WHITE, DAMAGE_FLASH_DURATION)

func _on_entity_died() -> void:
	if _death_started:
		return
	_death_started = true
	if not is_instance_valid(entity) or not is_instance_valid(entity.get_parent()):
		queue_free()
		return
	var scene_parent := entity.get_parent()
	set_process(false)
	set_physics_process(false)
	if _color_tween and _color_tween.is_running():
		_color_tween.kill()
	reparent(scene_parent, true)
	if entity.last_damage_type == Entity.DAMAGE_TYPES.STOMPED:
		_play_stomp_effect(scene_parent)
	else:
		_play_generic_death_effect(scene_parent)

func _play_stomp_effect(scene_parent: Node) -> void:
	var visual := _get_color_target()
	var visual_height := 0.0
	if visual is Sprite2D:
		visual_height = (visual as Sprite2D).get_rect().size.y
	if visual != null:
		visual.modulate = Color.WHITE
	scale.y *= 0.5
	position.y += visual_height * 0.25
	await get_tree().create_timer(DEATH_POSE_DURATION).timeout
	if not is_instance_valid(self):
		return
	_spawn_vanish_cloud(scene_parent)
	queue_free()

func _play_generic_death_effect(scene_parent: Node) -> void:
	_spawn_vanish_cloud(scene_parent)
	queue_free()

func _spawn_vanish_cloud(scene_parent: Node) -> void:
	if is_instance_valid(scene_parent) and not scene_parent.is_queued_for_deletion():
		var cloud := VANISH_CLOUD.instantiate() as Node2D
		scene_parent.add_child(cloud)
		cloud.global_position = global_position

func _get_color_target() -> CanvasItem:
	if not sprite_path.is_empty():
		var target := get_node_or_null(sprite_path) as CanvasItem
		if target != null:
			return target
	return self as CanvasItem
