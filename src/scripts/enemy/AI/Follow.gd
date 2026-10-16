class_name FollowBehavior
extends EnemyBehavior

@export var speed: float = 200.0

func tick(enemy: CharacterBody2D, _delta: float) -> void:
	var player = GameManager.player
	
	if player:
		var direction = (player.global_position - enemy.global_position).normalized()
		enemy.velocity.x = direction.x * speed
	else:
		enemy.velocity.x = 0
