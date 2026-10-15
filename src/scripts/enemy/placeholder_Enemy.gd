extends CharacterBody2D

@export var MAXHP = 5
@export var behavior: EnemyBehavior
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var HP = 0

func _ready() -> void:
	HP = MAXHP

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if self.position.y >= 128 or HP == 0:
		print("Removed: ", self)
		queue_free()
		
	behavior.tick(self, delta)
	
	move_and_slide()

func hurt():
	HP -= 1
