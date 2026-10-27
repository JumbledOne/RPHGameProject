extends Button

@export var level_selector_sample: TextureButton

func _pressed() -> void:
	var button_group: ButtonGroup = level_selector_sample.button_group
	var level: int = button_group.get_pressed_button().level
	InterfaceManager.do_on_transition(GameManager.start_game.bind(level))
