class_name Projectile
extends Area2D

@export var speed := 240.0
@export var lifetime := 3.0
@export var damage := 1
@export var impact_radius := 0.0
@export var applies_blindness := false
@export var rotates := true
var direction := 1.0
var friendly := false
var age := 0.0
var spent := false

func launch(facing: float, is_friendly: bool = false) -> void:
	direction = facing
	friendly = is_friendly

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	if get_node_or_null("CollisionShape2D") == null:
		var collider := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 7
		collider.shape = shape
		add_child(collider)
	body_entered.connect(_hit)

func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	if spent:
		return
	var target := global_position + Vector2(direction * speed * delta, 0)
	var query := PhysicsRayQueryParameters2D.create(global_position, target, 1)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		global_position = target
	else:
		global_position = hit.position
		_hit(hit.collider)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and rotates:
		sprite.rotation += delta * 5

func _hit(body: Node2D) -> void:
	if spent or (friendly and body.is_in_group("player")) or (not friendly and body.is_in_group("enemies")):
		return
	spent = true
	if friendly:
		if impact_radius > 0:
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if enemy.global_position.distance_to(global_position) < impact_radius:
					enemy.hurt(damage)
			var burst := Node2D.new()
			burst.set_script(preload("res://effects/impact_burst.gd"))
			get_parent().add_child(burst)
			burst.global_position = global_position
		elif body.is_in_group("enemies"):
			body.hurt(damage)
	elif body.is_in_group("player"):
		body.hurt(damage)
		if applies_blindness and body is Entity:
			body.add_status_effect(BlindnessEffect.new())
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "scale", Vector2(2, 2), 0.12)
		tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.12)
		tween.tween_callback(queue_free)
	else:
		queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
