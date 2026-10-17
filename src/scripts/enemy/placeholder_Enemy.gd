extends Entity

@export var behavior: EnemyBehavior

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if position.y >= 128:
		print("Removed: ", self)
		queue_free()
		
	behavior.tick(self, delta)
	
	move_and_slide()
