class_name CampaignPickup
extends Area2D
## Shared bobbing, collision and collection flow for campaign pickups.

var taken := false
var age := 0.0
var sprite: Sprite2D

func _ready() -> void:
	sprite = get_node_or_null("Sprite2D")
	collision_layer = 0
	collision_mask = 1
	if get_node_or_null("CollisionShape2D") == null:
		var collider := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 19.0
		collider.shape = circle
		add_child(collider)
	_on_spawned()
	body_entered.connect(_collect)

func _process(delta: float) -> void:
	age += delta
	if sprite:
		sprite.position.y = sin(age * 3.0) * 3.0
		_animate_sprite()

func _on_spawned() -> void:
	pass

func _animate_sprite() -> void:
	pass

func _apply_to_player(_player: PlayerEntity) -> void:
	pass

func _play_collect_sound() -> void:
	play_audio(preload("res://assets/audio/sfx/eat.wav"))

func play_audio(stream: AudioStream) -> void:
	var sound := AudioStreamPlayer.new()
	sound.volume_db = -12.0
	sound.stream = stream
	sound.finished.connect(sound.queue_free)
	get_parent().add_child(sound)
	sound.play()

func _collect(body: Node2D) -> void:
	if taken or not body is PlayerEntity:
		return
	taken = true
	_apply_to_player(body)
	_play_collect_sound()
	queue_free()
