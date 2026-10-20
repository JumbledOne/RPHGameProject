extends Node2D

@onready var player: PlatformerEntity = $".."
@onready var run_particles: CPUParticles2D = $RunParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const BASE_ANIM_SCALE: float = 2.0
const RUNNING_ANIM_SCALE: float = 4.0

var _reached_peak: bool = false
var last_facing_right: bool = true
var tween: Tween

func _ready() -> void:
	player.jumped.connect(_on_jumped)
	player.damaged.connect(_on_damaged)
	#player.sprint_changed.connect(_on_sprint_changed)
	
func _process(_delta: float) -> void:
	var on_floor: bool = player.is_on_floor()
	#run_particles.emitting = player.get_is_sprinting() and on_floor
	# Movement Animations
	if on_floor:
		animation_player.speed_scale = RUNNING_ANIM_SCALE if player.get_is_sprinting() else BASE_ANIM_SCALE
		if player.horizontal_movement > 0:
			last_facing_right = true
			animation_player.play("walk_right")
		elif player.horizontal_movement < 0:
			last_facing_right = false
			animation_player.play("walk_left")
		else: # Exactly zero
			if last_facing_right:
				animation_player.play("face_right")
			else:
				animation_player.play("face_left")
	# Check if about to land
	elif player.velocity.y > 0:
		if not _reached_peak:
			if last_facing_right:
				animation_player.play("land_right")
			else:
				animation_player.play("land_left")
		_reached_peak = true
		
func _on_jumped():
	_reached_peak = false # Reset this variable
	if last_facing_right:
		animation_player.play("jump_right")
	else:
		animation_player.play("jump_left")

func _on_damaged():
	# Test animation only
	# Feel free to change later
	if tween:
		tween.kill()
	tween = create_tween()
	modulate = Color.RED
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
