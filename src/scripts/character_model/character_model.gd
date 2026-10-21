extends Node2D
# NOTE
# This uses an AnimationPlayer and AtlasTexture. It intentionally doesn't use an AnimatedSprite2D
# This is because you can't easily change the base textures when using SpriteFrames
# So we manually animate the atlas texture using an animation player since all 
# sprite sheets are consistent anyway

@onready var entity: PlatformerEntity = $".."
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const DAMAGE_ANIM_SCALE: float = 2.0
const LANDING_ANIM_SCALE: float = 4.0
const JUMPING_ANIM_SCALE: float = 2.0
const WALKING_ANIM_SCALE: float = 3.0
const RUNNING_ANIM_SCALE: float = 5.0

var _can_animate: bool = true
var _reached_peak: bool = false
var last_facing_right: bool = true

func _ready() -> void:
	entity.jumped.connect(_on_jumped)
	entity.damaged.connect(_on_damaged)
	entity.died.connect(_on_died)
	
func _process(_delta: float) -> void:
	# Movement Animations
	if entity.is_on_floor():
		# Exactly zero
		if entity.horizontal_movement == 0:
			_play_animation("face_left", "face_right")
		# Walking
		else:
			last_facing_right = entity.horizontal_movement > 0
			var anim_scale: float = RUNNING_ANIM_SCALE if entity.get_is_sprinting() else WALKING_ANIM_SCALE
			_play_animation("walk_left", "walk_right", anim_scale)
	# Check if about to land
	elif entity.velocity.y > 0:
		if not _reached_peak:
			_play_animation("land_left", "land_right", LANDING_ANIM_SCALE, true)
		_reached_peak = true
		
func _on_jumped():
	_reached_peak = false # Reseting the variable
	_play_animation("jump_left", "jump_right", JUMPING_ANIM_SCALE, false, true)

func _on_damaged():
	_play_animation("hit_left", "hit_right", DAMAGE_ANIM_SCALE, true, true)

func _on_died():
	pass
	
# # # # # # # # # # # #
# Helpers
## Remember to use this helper function and not call animation player directly
func _play_animation(left_anim: StringName, right_anim: StringName, anim_scale: float = 1.0, until_end: bool = false, override_previous: bool = false):
	if override_previous:
		_can_animate = true
	if not _can_animate:
		return
	animation_player.speed_scale = anim_scale
	if last_facing_right:
		animation_player.play(right_anim)
	else:
		animation_player.play(left_anim)
	if until_end:
		_can_animate = false
		animation_player.animation_finished.connect(
				func(_anim_name: StringName): _can_animate = true,
				CONNECT_ONE_SHOT
		)
