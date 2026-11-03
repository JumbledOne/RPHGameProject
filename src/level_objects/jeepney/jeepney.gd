extends HazardPlatform
## Jeepney with a random atlas color and signed horizontal velocity in pixels/second.

const TILEMAP := preload("res://assets/gfx/sprites/tilemap-updated.png")
const TEXTURE_REGIONS: Array[Rect2] = [
	Rect2(208, 144, 224, 80),
	Rect2(208, 240, 224, 80),
	Rect2(208, 336, 224, 80),
]

@export var velocity: float = -85.3333:
	set(value):
		velocity = value
		_update_velocity()

func _ready() -> void:
	var texture := AtlasTexture.new()
	texture.atlas = TILEMAP
	texture.region = TEXTURE_REGIONS.pick_random()
	$Sprite2D.texture = texture
	_update_velocity()
	super()

func _update_velocity() -> void:
	direction = Vector2(signf(velocity), 0.0)
	speed = absf(velocity)
	if has_node("Sprite2D") and not is_zero_approx(velocity):
		$Sprite2D.flip_h = velocity < 0.0

func enable_movement() -> void:
	if enabled:
		return
	super()
	$AppearSound.play()
	_update_running_sound()

func _physics_process(delta: float) -> void:
	super(delta)
	_update_running_sound()

func _update_running_sound() -> void:
	var sound: AudioStreamPlayer2D = $RunningSound
	if enabled and moving and not is_zero_approx(velocity):
		if not sound.playing:
			sound.play()
	else:
		sound.stop()
