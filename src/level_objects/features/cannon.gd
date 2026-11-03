extends Node2D
@export var fire_interval := 2.8
var clock := 0.0
var on_screen := false
var next_fire_delay := 1.0
@onready var weapon: Weapon = $Weapon
@onready var cannon_fire: AudioStreamPlayer2D = $CannonFire
@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
const CANNON_FIRE_EFFECT := preload("res://effects/cannon_fire_effect/cannon_fire_effect.tscn")

const INITIAL_FIRE_DELAY: float = 0.2

func _ready() -> void:
	weapon.position.x = -absf(weapon.position.x)
	visibility_notifier.screen_entered.connect(_on_screen_entered)
	visibility_notifier.screen_exited.connect(_on_screen_exited)
	if visibility_notifier.is_on_screen():
		_on_screen_entered()

func _on_screen_entered() -> void:
	on_screen = true
	clock = 0.0
	next_fire_delay = INITIAL_FIRE_DELAY

func _on_screen_exited() -> void:
	on_screen = false

func _physics_process(delta: float) -> void:
	if not on_screen or not LevelManager.game_started or not is_instance_valid(GameManager.player):
		return
	clock += delta
	if clock >= next_fire_delay:
		clock = 0
		next_fire_delay = fire_interval
		if weapon.fire(-1.0) != null:
			var effect := CANNON_FIRE_EFFECT.instantiate() as CPUParticles2D
			effect.position = weapon.position
			effect.direction = Vector2.LEFT
			add_child(effect)
			cannon_fire.play()
