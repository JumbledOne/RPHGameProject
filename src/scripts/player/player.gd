extends CharacterBody2D

# Controlled by external controllers
# This script decides only how to move.
# Control is in another script
var movement: Vector2
var jump_velocity: float = 100
var gravity_factor: float = 1

const MAX_HEALTH: int = 3
var health: int = MAX_HEALTH:
	set(v):
		var new_health: int = clamp(v, 0, MAX_HEALTH)
		var health_diff: int = new_health - health
		health = new_health
		health_changed.emit(health_diff)
		if health <= 0:
			die()
			
signal died
signal health_changed(diff: int)
signal jumped
signal sprint_changed

# Health
func die():
	died.emit()
	queue_free()

# Movement
func _physics_process(delta: float) -> void:
	# Movement
	
	# Gravity
	velocity.y -= -980 * delta * gravity_factor
	# Apply
	move_and_slide()
