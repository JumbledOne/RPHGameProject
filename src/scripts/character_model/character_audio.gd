extends Node2D

@onready var entity: Entity = get_parent().get_parent()
@onready var damage_player: CombinedAudioPlayer2D = $DamageAudio
@onready var jump_player: CombinedAudioPlayer2D = $JumpAudio


func _ready() -> void:
	entity.jumped.connect(_on_jumped)
	entity.damaged.connect(_on_damaged)


func _on_jumped() -> void:
	jump_player.play_audio()


func _on_damaged() -> void:
	damage_player.play_audio()
	if entity.health <= 0:
		damage_player.reparent(get_tree().current_scene, true)
