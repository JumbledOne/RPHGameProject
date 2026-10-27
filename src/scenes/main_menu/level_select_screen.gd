extends Control

const TRIBES: Dictionary = {
	"urban": "Urban Person",
	"ata": "Ata of Paquibato",
	"bagobo": "Bagobo Tagabawa",
}

# Dates/descriptions are PLACEHOLDERS mf. Replace with the other guys' researched text.
const LEVEL_INFO: Array[Dictionary] = [
	{
		"date": "1700s", 
		"title": "Pre-Colonial Davao",
		"desc": "Indigenous tribes live and trade along the Davao Gulf.",
	},
	{
		"date": "1800s", 
		"title": "Spaniards Conquered Davao",
		"desc": "Spanish colonizers arrive and take control of the region.",
	},
	{
		"date": "1900s", 
		"title": "Arrival of the Japanese",
		"desc": "Japanese settlers arrive and Davao City is established.",
	},
	{
		"date": "1940s", 
		"title": "World War II",
		"desc": "Davao during the war years.",
	},
	{
		"date": "Today", 
		"title": "Davao Today",
		"desc": "Modern Davao, the city we know now.",
	},
]

var level_group: ButtonGroup

func _ready() -> void:
	# Level buttons
	var level_button: PackedScene = load("uid://duh7we0h3louf")
	level_group = ButtonGroup.new()
	for i in GameManager.get_level_count():
		var info_dict: Dictionary = LEVEL_INFO[i]
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
