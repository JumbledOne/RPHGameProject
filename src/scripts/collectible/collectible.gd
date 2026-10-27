class_name Collectible
extends Area2D

@export var collect_effect: PackedScene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	GameManager.register_collectible()
	sprite.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body != GameManager.player:
		return
	GameManager.collect()
	if collect_effect:
		var effect := collect_effect.instantiate()
		ScenePlacer.fpx_add_child(effect)
		effect.global_position = global_position
	queue_free()
