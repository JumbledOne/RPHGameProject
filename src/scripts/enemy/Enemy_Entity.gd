class_name Enemy_Entity
extends Entity

@onready var behaviorManager: Enemy_Behavior = $BehaviorManager
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D

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

func _ready() -> void:
	behaviorManager.attack_Component.animation_request.connect(_change_animation)
	behaviorManager.movement_Component.flip_sprite.connect(_flip_sprite)

func _process(delta: float) -> void:
	behaviorManager.attack_Component.tick(self, delta)

func _physics_process(delta: float) -> void:
	behaviorManager.movement_Component.tick(self, delta)
	move_and_slide()


#signals
func _flip_sprite(direction: bool) -> void:
	$AnimatedSprite2D.flip_h = direction

func _change_animation(animation_name: String) -> void:
	$AnimatedSprite2D.play(animation_name)
