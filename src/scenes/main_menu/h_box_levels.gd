extends HBoxContainer


func _unhandled_input(event: InputEvent) -> void:
	var direction: int = 0
	if event.is_action_pressed("ui_left"):
		direction = -1
	elif event.is_action_pressed("ui_right"):
		direction = 1
	if direction == 0:
		return

	var button_group: ButtonGroup = get_meta("level_selector_button_group", null)
	if button_group == null:
		return

	var buttons: Array[BaseButton] = button_group.get_buttons()
	if buttons.is_empty():
		return

	var selected_index: int = buttons.find(button_group.get_pressed_button())
	var next_index: int = clampi(selected_index + direction, 0, buttons.size() - 1)
	buttons[next_index].button_pressed = true
	get_viewport().set_input_as_handled()
