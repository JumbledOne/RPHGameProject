extends Control

func _ready() -> void:
	%PlayButton.pressed.connect(_on_play)
	%QuitButton.pressed.connect(get_tree().quit)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")
