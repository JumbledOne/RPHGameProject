extends Sprite2D

var velocity: Vector2
var angular_velocity: float = 10

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	velocity.y += 980 * delta
	position += velocity * delta
	rotation += angular_velocity * delta
	if position.y > 128:
		queue_free()
	
func throw():
	velocity.x = 256
	set_process(true)
