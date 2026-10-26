class_name ShootAttackComponent
extends Component

const BulletScene = preload("res://scripts/enemy/Bullet.tscn")

var set_timer: float = 3.0
var timer: float = set_timer

func tick(enemy: Enemy_Entity, delta: float) -> void:
	
	var direction: bool
	
	if GameManager.player.global_position.x > global_position.x:
		direction = true  # Shoot right
	else:
		direction = false # Shoot left
	
	if timer <= 0.0:
		fire_bullet(direction)
		timer = set_timer
	
	timer -= delta
	

func fire_bullet(is_facing_right: bool) -> void:
	var bullet = BulletScene.instantiate()
	
	bullet.global_position = global_position
	
	if is_facing_right:
		bullet.direction = 1.0
	else:
		bullet.direction = -1.0
		var sprite = bullet.get_node_or_null("Sprite2D")
		if sprite:
			sprite.flip_h = true

	get_tree().current_scene.add_child(bullet)
