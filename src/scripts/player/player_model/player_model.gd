extends Node2D

@onready var player: PlatformerEntity = $".."

func _ready() -> void:
	player.sprint_changed.connect(_on_sprint_changed)
	
func _on_sprint_changed():
	pass
