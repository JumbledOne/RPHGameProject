extends Control

const TRIBES: Dictionary = {
	"urban": "Urban Person",
	"ata": "Ata of Paquibato",
	"bagobo": "Bagobo Tagabawa",
}

const LEVEL_INFO_PATH: String = "res://assets/data/level_info.json"

var level_group: ButtonGroup

func _ready() -> void:
	var level_info: Array = _load_level_info()

	# Level buttons
	var level_button: PackedScene = load("uid://duh7we0h3louf")
	level_group = ButtonGroup.new()
	for i in GameManager.get_level_count():
		var info_dict: Dictionary = level_info["levels"][i]
		var btn: Button = level_button.instantiate()
		btn.set_level_data(i, info_dict)
		btn.button_group = level_group
		btn.mouse_entered.connect(func(): %DescriptionLabel.text = info_dict["desc"])
		btn.mouse_exited.connect(func(): %DescriptionLabel.text = "")
		%LevelsBox.add_child(btn)

	# Tribe buttons
	var tribe_group: ButtonGroup = ButtonGroup.new()
	for key in TRIBES.keys():
		var btn: Button = Button.new()
		btn.text = TRIBES[key]
		btn.toggle_mode = true
		btn.button_group = tribe_group
		btn.button_pressed = is_instance_of(GameManager.player_class, _tribe_to_class(key).get_script())
		btn.pressed.connect(func(): GameManager.player_class = _tribe_to_class(key))
		%TribeBox.add_child(btn)

	%StartButton.pressed.connect(func(): GameState.start_level(GameState.selected_level))
	%BackButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))


func _load_level_info() -> Array:
	var file: FileAccess = FileAccess.open(LEVEL_INFO_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open %s" % LEVEL_INFO_PATH)
		return []

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and parsed.has("levels") and parsed["levels"] is Array:
		return parsed["levels"]

	push_error("Expected an array in %s" % LEVEL_INFO_PATH)
	return []
		
		
func _on_start_button_pressed() -> void:
	var button: Button = level_group.get_pressed_button()
	if button:
		InterfaceManager.do_on_transition(GameManager.start_game.bind(button.level))

func _tribe_to_class(tribe: String) -> PlayerClass:
	match tribe:
		"ata":
			return AtaCharacter.new()
		"bagobo":
			return BagoboCharacter.new()
		_:
			return UrbanCharacter.new()
