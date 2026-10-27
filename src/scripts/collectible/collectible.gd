class_name Collectible
extends Area2D
# A pickup that counts towards the level's collectible total

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	GameManager.register_collectible()
	sprite.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body != GameManager.player:
		return
	GameManager.collect()
	queue_free()
