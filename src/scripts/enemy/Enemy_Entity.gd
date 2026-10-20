class_name Enemy_Entity
extends Entity

@onready var behaviorManager: Enemy_Behavior = $BehaviorManager

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

func _process(delta: float) -> void:
	behaviorManager.attack_Component.tick(self, delta)

func _physics_process(delta: float) -> void:
	behaviorManager.movement_Component.tick(self, delta)
	move_and_slide()
