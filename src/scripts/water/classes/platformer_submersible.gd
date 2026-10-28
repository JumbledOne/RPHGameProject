class_name PlatformerSubmersible
extends Submersible
# Submersible for PlatformerEntity
# Modifies its movement factors while in water

const GRAVITY_FACTOR: float = 0.1
const SPEED_FACTOR: float = 0.6
const ACCELERATION_FACTOR: float = 0.6
const JUMP_FACTOR: float = 0.2
const TERMINAL_VELOCITY_FACTOR: float = 0.1
const ALLOW_MIDAIR_JUMP: bool = true

@onready var _platformer: PlatformerEntity = get_parent() as PlatformerEntity

func _ready() -> void:
	super()
	if not _platformer:
		push_error("PlatformerSubmersible's parent must be a PlatformerEntity: " + str(get_parent().get_path()))
		return
	water_entered.connect(_on_p_entity_entered)
	water_exited.connect(_on_p_entity_exited)

func _on_p_entity_entered() -> void:
	_platformer.gravity_factor = GRAVITY_FACTOR
	_platformer.speed_factor = SPEED_FACTOR
	_platformer.acceleration_factor = ACCELERATION_FACTOR
	_platformer.jump_factor = JUMP_FACTOR
	_platformer.terminal_velocity_factor = TERMINAL_VELOCITY_FACTOR
	_platformer.allow_midair_jump = ALLOW_MIDAIR_JUMP

func _on_p_entity_exited() -> void:
	_platformer.gravity_factor = 1.0
	_platformer.speed_factor = 1.0
	_platformer.acceleration_factor = 1.0
	_platformer.jump_factor = 1.0
	_platformer.terminal_velocity_factor = 1.0
	_platformer.allow_midair_jump = false
