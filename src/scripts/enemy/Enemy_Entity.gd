class_name Enemy_Entity
extends Entity

enum AnimState { IDLE, WALK, ATTACK, HURT, DEATH }

const LOCOMOTION_STATES := [AnimState.IDLE, AnimState.WALK]

@onready var behaviorManager: Enemy_Behavior = $BehaviorManager
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D

# Game stuff
var is_jumping: bool = false
var jump_timer: float = 0.0

@export_category("Enemy stats")
@export var speed = 200.0
@export var jump_duration: float = 0.25
@export var jump_speed: float = -300.0

@export_category("Animation")
@export var idle_animation: StringName = &"idle"
@export var walk_animation: StringName = &"walk"
@export var attack_animation: StringName = &"attack"
@export var hurt_animation: StringName = &"hurt"
@export var walk_epsilon: float = 1.0

var _anim_state: AnimState = AnimState.IDLE
var _anim_locked: bool = false
var _warned_clips: Dictionary = {}

func start_jump() -> void:
	if not is_jumping:
		is_jumping = true
		jump_timer = jump_duration

func _ready() -> void:
	behaviorManager.attack_Component.animation_request.connect(_change_animation)
	behaviorManager.movement_Component.flip_sprite.connect(_flip_sprite)

	animatedSprite.animation_finished.connect(_on_animation_finished)
	damaged.connect(play_hurt)

	# Action clips must be non-looping, otherwise animation_finished never fires.
	_force_non_looping(_get_animation_name(AnimState.ATTACK))
	_force_non_looping(_get_animation_name(AnimState.HURT))

	_change_state(AnimState.IDLE, true)

func _process(delta: float) -> void:
	if !behaviorManager.attack_Component:
		return

	behaviorManager.attack_Component.tick(self, delta)

func _physics_process(delta: float) -> void:
	if behaviorManager.movement_Component:
		behaviorManager.movement_Component.tick(self, delta)
		move_and_slide()

	_update_locomotion_animation()

# # # # # # # # # # # #
# Public animation API

func play_attack(clip: StringName = &"") -> void:
	if clip == &"":
		clip = _get_animation_name(AnimState.ATTACK)
	if not _has_clip(clip):
		_warn_missing_clip(clip)
		return
	_change_state(AnimState.ATTACK, true, clip)

func play_hurt() -> void:
	if _anim_state == AnimState.DEATH:
		return
	if not _has_clip(hurt_animation):
		_warn_missing_clip(hurt_animation)
		return
	_change_state(AnimState.HURT, true)

func die() -> void:
	_change_state(AnimState.DEATH, true)
	super.die()

# Virtual hooks for child enemies.
func _get_animation_name(state: AnimState) -> StringName:
	match state:
		AnimState.IDLE:
			return idle_animation
		AnimState.WALK:
			return walk_animation
		AnimState.ATTACK:
			return attack_animation
		AnimState.HURT:
			return hurt_animation
	return &""

# # # # # # # # # # # #
# State handling

func _change_state(next: AnimState, force: bool = false, clip_override: StringName = &"") -> void:
	if next == _anim_state and not force and clip_override == &"":
		return
	if not _can_enter(next):
		return

	# No death clip yet: freeze on the current frame.
	if next == AnimState.DEATH:
		_anim_state = next
		_anim_locked = true
		animatedSprite.stop()
		return

	var played := _apply_animation(next, clip_override, force)
	_anim_state = next
	_anim_locked = played and next in [AnimState.ATTACK, AnimState.HURT]

func _can_enter(next: AnimState) -> bool:
	if _anim_state == AnimState.DEATH:
		return false

	match next:
		AnimState.DEATH:
			return true
		AnimState.HURT:
			return true # Hurt interrupts anything, including attack.
		AnimState.ATTACK:
			return _anim_state in LOCOMOTION_STATES
		AnimState.IDLE, AnimState.WALK:
			return not _anim_locked
	return false

func _update_locomotion_animation() -> void:
	if _anim_locked or _anim_state == AnimState.DEATH:
		return

	var moving := velocity.length() > walk_epsilon
	_change_state(AnimState.WALK if moving else AnimState.IDLE)

func _apply_animation(state: AnimState, clip_override: StringName, force: bool) -> bool:
	var clip: StringName = clip_override
	if clip == &"":
		clip = _get_animation_name(state)

	if not _has_clip(clip):
		if state in LOCOMOTION_STATES:
			clip = _resolve_locomotion_clip()
		if not _has_clip(clip):
			_warn_missing_clip(_get_animation_name(state))
			return false

	if animatedSprite.animation != clip or not animatedSprite.is_playing():
		animatedSprite.play(clip)
	if force:
		animatedSprite.set_frame_and_progress(0, 0.0)
	return true

func _resolve_locomotion_clip() -> StringName:
	if _has_clip(&"default"):
		return &"default"

	var frames := animatedSprite.sprite_frames
	if frames == null:
		return &""

	var names := frames.get_animation_names()
	return StringName(names[0]) if not names.is_empty() else &""

func _force_non_looping(clip: StringName) -> void:
	var frames := animatedSprite.sprite_frames
	if frames and frames.has_animation(clip) and frames.get_animation_loop(clip):
		frames.set_animation_loop(clip, false)

func _on_animation_finished() -> void:
	if _anim_state in [AnimState.ATTACK, AnimState.HURT]:
		_anim_locked = false
		_change_state(AnimState.IDLE)

func _has_clip(clip: StringName) -> bool:
	return clip != &"" and animatedSprite.sprite_frames != null \
		and animatedSprite.sprite_frames.has_animation(clip)

func _warn_missing_clip(clip: StringName) -> void:
	if clip == &"" or _warned_clips.has(clip):
		return
	_warned_clips[clip] = true
	push_warning("%s: missing animation '%s'" % [name, clip])

# # # # # # # # # # # #
# Signals

func _flip_sprite(direction: bool) -> void:
	animatedSprite.flip_h = direction

# Called by attack components. "default" means "back to locomotion"; anything
# else is treated as an explicit attack clip so directional attacks keep working.
func _change_animation(animation_name: String) -> void:
	var requested := StringName(animation_name)
	var lower := animation_name.to_lower()

	if lower == "default" or lower == "idle" or requested == idle_animation:
		_anim_locked = false
		_change_state(AnimState.IDLE)
		return

	if lower == "walk" or requested == walk_animation:
		_anim_locked = false
		_change_state(AnimState.WALK)
		return

	if not _has_clip(requested):
		_warn_missing_clip(requested)
		return

	if "hurt" in lower or requested == hurt_animation:
		_change_state(AnimState.HURT, true, requested)
	elif "die" in lower:
		die()
	else:
		_change_state(AnimState.ATTACK, true, requested)
