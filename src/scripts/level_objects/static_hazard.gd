class_name StaticHazard
extends Area2D
## Contact damage for spikes, wire and other stationary obstacles.

@export_range(0, 10) var damage: int = 1
@export_range(0.1, 5.0) var damage_interval: float = 1.0
@export var knockback: Vector2 = Vector2.ZERO

var _cooldowns: Dictionary = {}

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitorable = false

func _physics_process(delta: float) -> void:
	for id in _cooldowns.keys():
		_cooldowns[id] -= delta
		if _cooldowns[id] <= 0.0:
			_cooldowns.erase(id)
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("hurt"):
			var id := body.get_instance_id()
			if _cooldowns.has(id):
				continue
			_cooldowns[id] = damage_interval
			if body is CharacterBody2D:
				var direction := signf(body.global_position.x - global_position.x)
				if is_zero_approx(direction):
					direction = -1.0
				body.velocity += Vector2(absf(knockback.x) * direction, knockback.y)
			if damage > 0:
				body.hurt(damage)
