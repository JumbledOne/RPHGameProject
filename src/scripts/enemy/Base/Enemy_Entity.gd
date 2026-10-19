@abstract class_name Enemy_Entity
extends Entity

# should be called inside func _process()
@onready var attack_Component = $AttackComponent

# should be called inside func _physics_process()
# so movement is just handling how they move while attack components shouldn't be moving the entity
@onready var movement_Component = $MovementComponent

# Game stuff
var is_jumping: bool = false
var jump_timer: float = 0.0

@export_category("Enemy stats")
@export var speed = 200.0
@export var jump_duration: float = 0.25
@export var jump_speed: float = -300.0

func start_jump() -> void:
	if not is_jumping:
		is_jumping = true
		jump_timer = jump_duration
