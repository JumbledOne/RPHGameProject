@tool
class_name TwoPointMovingPlatform
extends BaseMovingPlatform

@export var pos1: Vector2 # Always the left
@export var pos2: Vector2 # Always the right
@export var travel_time: float = 2
@export var starting_direction: DIRECTION
	
enum DIRECTION {
	LEFT,
	RIGHT
}

var velocity: float = 0

func _ready() -> void:
	if travel_time <= 0.0:
		push_warning("TwoPointMovingPlatform travel_time must be greater than zero.")
		return

	var dist: float = pos1.distance_to(pos2)
	velocity = dist / travel_time
	if pos1.x > pos2.x:
		var t: Vector2 = pos1
		pos1 = pos2
		pos2 = t

func _physics_process(delta: float) -> void:
	match starting_direction:
		DIRECTION.LEFT:
			position = position.move_toward(pos1, velocity * delta)
			if position.is_equal_approx(pos1):
				starting_direction = DIRECTION.RIGHT
		DIRECTION.RIGHT:
			position = position.move_toward(pos2, velocity * delta)
			if position.is_equal_approx(pos2):
				starting_direction = DIRECTION.LEFT
