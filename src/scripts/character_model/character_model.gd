extends EntitySprite
# NOTE
# This uses an AnimationPlayer and AtlasTexture. It intentionally doesn't use an AnimatedSprite2D
# This is because you can't easily change the base textures when using SpriteFrames
# So we manually animate the atlas texture using an animation player since all 
# sprite sheets are consistent anyway

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var effect_floor: Marker2D = $EffectFloor

const JUMP_EFFECT: PackedScene = preload("res://effects/character_effects/jump_effect.tscn")
const LAND_EFFECT: PackedScene = preload("res://effects/character_effects/land_effect.tscn")

const DAMAGE_ANIM_SCALE: float = 2.0
const LANDING_ANIM_SCALE: float = 4.0
const JUMPING_ANIM_SCALE: float = 2.0
const WALKING_ANIM_SCALE: float = 3.0
const RUNNING_ANIM_SCALE: float = 5.0

# Animation vars
var _can_animate: bool = true
var last_facing_right: bool = true
# Jump vars
# Tracked so that the jump and land animations play once
# We don't use the jumped signal so any entity can use them
var _jumped: bool = false
var _reached_peak: bool = false
func _ready() -> void:
	super._ready()
	# Submersible renames itself when ready, so wait for the entity
	if not entity.is_node_ready():
		await entity.ready
	var platformer := entity as PlatformerEntity
	if platformer != null:
		platformer.jumped.connect(_on_jumped)
		platformer.landed.connect(_on_landed)
	var submersible: Submersible = entity.get_node_or_null("Submersible")
	if submersible:
		submersible.water_entered.connect(_on_water_entered)
		submersible.water_exited.connect(_on_water_exited)

func _on_jumped() -> void:
	_spawn_effect(JUMP_EFFECT)

func _on_landed() -> void:
	_spawn_effect(LAND_EFFECT)

func _spawn_effect(effect_scene: PackedScene) -> void:
	var scene_parent := entity.get_parent() as Node2D
	if scene_parent == null:
		return
	var effect := effect_scene.instantiate() as Node2D
	effect.transform = scene_parent.global_transform.affine_inverse() * effect_floor.global_transform
	effect.z_index = z_index
	scene_parent.add_child(effect)
	
func _process(_delta: float) -> void:
	# Movement Animations
	if entity.is_on_floor():
		# Reset jump vars
		_jumped = false
		_reached_peak = false
		# Exactly zero
		if entity.horizontal_movement == 0:
			_play_animation("face_left", "face_right")
		# Walking
		else:
			last_facing_right = entity.horizontal_movement > 0
			var anim_scale: float = RUNNING_ANIM_SCALE if entity.get_is_sprinting() else WALKING_ANIM_SCALE
			_play_animation("walk_left", "walk_right", anim_scale)
	# Check if about to land
	else:
		# Upward
		if entity.velocity.y < 0:
			if not _jumped:
				_play_animation("jump_left", "jump_right", JUMPING_ANIM_SCALE, false, true)
			_jumped = true
		# Downward
		else:
			if not _reached_peak:
				_play_animation("land_left", "land_right", LANDING_ANIM_SCALE, true)
			_reached_peak = true

func _on_damaged():
	_play_animation("hit_left", "hit_right", DAMAGE_ANIM_SCALE, true, true)

func _on_water_entered():
	pass

func _on_water_exited(_from_top: bool):
	pass
	
func set_texture(atlas_tex: AtlasTexture):
	$CharacterSprite.texture = atlas_tex
	
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
