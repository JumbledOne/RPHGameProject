class_name Pickup
extends Area2D

var taken := false
var age := 0.0
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	if get_node_or_null("CollisionShape2D") == null:
		var collider := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 19
		collider.shape = circle
		add_child(collider)
	body_entered.connect(_collect)

func _process(delta: float) -> void:
	age += delta
	if sprite:
		sprite.position.y = sin(age * 3) * 3

func _collect(body: Node2D) -> void:
	if taken or not body is PlayerEntity:
		return
	taken = true
	_apply_effect(body as PlayerEntity)
	var sound := AudioStreamPlayer.new()
	sound.volume_db = -12
	get_parent().add_child(sound)
	_play_sound(sound)
	queue_free()

func _apply_effect(_body: PlayerEntity) -> void:
	pass

func _play_sound(sound: AudioStreamPlayer) -> void:
	sound.stream = preload("res://assets/audio/sfx/eat.wav")
	sound.finished.connect(sound.queue_free)
	sound.play()
