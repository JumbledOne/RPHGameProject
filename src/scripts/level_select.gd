extends Control

const TRIBES := {
	"urban": "Urban Person",
	"ata": "Ata of Paquibato",
	"bagobo": "Bagobo Tagabawa",
}

func _ready() -> void:
	# --- Level buttons ---
	var level_group := ButtonGroup.new()
	for i in GameState.LEVELS.keys():
		var info = GameState.LEVELS[i]
		var btn := Button.new()
		btn.text = "Level %d - %s" % [i, info["title"]]
		btn.toggle_mode = true
		btn.button_group = level_group
		btn.button_pressed = (i == GameState.selected_level)
		btn.pressed.connect(func(): GameState.selected_level = i)
		btn.mouse_entered.connect(func(): %DescriptionLabel.text = info["desc"])
		btn.mouse_exited.connect(func(): %DescriptionLabel.text = "")
		%LevelsBox.add_child(btn)

	# Tribe buttons
	var tribe_group := ButtonGroup.new()
	for key in TRIBES.keys():
		var btn := Button.new()
		btn.text = TRIBES[key]
		btn.toggle_mode = true
		btn.button_group = tribe_group
		btn.button_pressed = (key == GameState.selected_tribe)
		btn.pressed.connect(func(): GameState.selected_tribe = key)
		%TribeBox.add_child(btn)

	%StartButton.pressed.connect(func(): GameState.start_level(GameState.selected_level))
	%BackButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))
		
		
