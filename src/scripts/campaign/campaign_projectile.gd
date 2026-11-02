class_name CampaignProjectile
extends Area2D
## Common travel and collision behavior for authored projectile scenes.

@export var speed: float = 240.0
@export var lifetime: float = 3.0

var velocity := Vector2.ZERO
var friendly := false
var age := 0.0
var spent := false
var sprite: Sprite2D

func setup(direction: float, is_friendly: bool = false) -> void:
	velocity = Vector2(direction * (430.0 if is_friendly else speed), 0.0)
	friendly = is_friendly

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	sprite = get_node_or_null("Sprite2D")
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 7.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_hit)

func _physics_process(delta: float) -> void:
	age += delta
	if age > lifetime:
		queue_free()
		return
	var query := PhysicsRayQueryParameters2D.create(global_position, global_position + velocity * delta, 1)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit.position
		_hit(hit.collider)
	else:
		position += velocity * delta
	if sprite:
		sprite.rotation += delta * 5.0

func _hit(body: Node2D) -> void:
	if spent:
		return
	if friendly and body.is_in_group("player"):
		return
	if not friendly and body.is_in_group("enemies"):
		return
	spent = true
	if friendly:
		var burst := Node2D.new()
		burst.set_script(preload("res://scripts/campaign/impact_burst.gd"))
		get_parent().add_child(burst)
		burst.global_position = global_position
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.global_position.distance_to(global_position) < 62.0:
				enemy.hurt(1)
	else:
		if body.is_in_group("player"):
			body.hurt(1)
			_apply_hit_effect(body)
	velocity = Vector2.ZERO
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "scale", Vector2(2, 2), 0.12)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.12)
		tween.tween_callback(queue_free)
	else:
		queue_free()

func _apply_hit_effect(_body: Node2D) -> void:
	pass
