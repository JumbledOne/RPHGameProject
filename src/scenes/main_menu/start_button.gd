extends Button

@export var level_selector_sample: TextureButton

func _pressed() -> void:
	var button_group: ButtonGroup = level_selector_sample.button_group
	var selected_button: BaseButton = button_group.get_pressed_button()
	if selected_button:
		selected_button.call("start_level")
