extends Area2D
## Short-lived projectiles belong to the level so retries remove them atomically.
var velocity := Vector2.ZERO
var friendly := false
var projectile_kind := ""
var lifetime := 3.0
var age := 0.0
var spent := false
var sprite: Sprite2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 7
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
		sprite.rotation += delta * 5

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
		# Impact burst does exactly one heart to each enemy in a small radius.
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.global_position.distance_to(global_position) < 62:
				enemy.hurt(1)
	else:
		if body.is_in_group("player"):
			body.hurt(1)
			if projectile_kind == "spanish":
				body.add_status_effect(BlindnessEffect.new())
	velocity = Vector2.ZERO
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "scale", Vector2(2, 2), 0.12)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.12)
		tween.tween_callback(queue_free)
	else:
		queue_free()
