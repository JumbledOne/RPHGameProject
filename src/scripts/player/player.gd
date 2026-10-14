extends PlatformerEntity

@export_category("World")
@export var death_altitude: float = 128 # Below this point the player dies

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

func _physics_process(delta: float) -> void:
	super(delta)
	if position.y >= death_altitude:
		die()

# # # # # # # # # # # #
# Health
func die():
	died.emit()
	queue_free()
