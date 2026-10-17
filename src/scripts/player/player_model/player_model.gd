extends Node2D

@onready var player: PlatformerEntity = $".."
@onready var run_particles: CPUParticles2D = $RunParticles

var tween: Tween

func _ready() -> void:
	player.jumped.connect(_on_jumped)
	player.damaged.connect(_on_damaged)
	
func _process(_delta: float) -> void:
	var on_floor: bool = player.is_on_floor()
	run_particles.emitting = player.get_is_sprinting() and on_floor

func _on_jumped():
	pass

func _on_damaged():
	# Test animation only
	# Feel free to change later
	if tween:
		tween.kill()
	tween = create_tween()
	modulate = Color.RED
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
