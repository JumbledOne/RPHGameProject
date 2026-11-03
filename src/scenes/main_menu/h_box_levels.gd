extends HBoxContainer

func _ready() -> void:
	InterfaceManager.ui_requested.connect(_on_ui_requested)
	_select_next_level()

func _on_ui_requested(node_name: String) -> void:
	if node_name == "MainMenu":
		_select_next_level()

func _select_next_level() -> void:
	await get_tree().create_timer(0.5).timeout
	var button_group: ButtonGroup = get_meta("level_selector_button_group", null)
	if button_group == null:
		return
	var buttons: Array[BaseButton] = _get_level_buttons(button_group)
	if buttons.is_empty():
		return
	var target_level: int = clampi(LevelManager.last_level_won + 1, 0, buttons.size() - 1)
	for button: BaseButton in buttons:
		if button.get("level") == target_level:
			button.button_pressed = true
			return


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

	var buttons: Array[BaseButton] = _get_level_buttons(button_group)
	if buttons.is_empty():
		return

	var selected_index: int = buttons.find(button_group.get_pressed_button())
	if selected_index == -1:
		selected_index = -1 if direction > 0 else 0
	var next_index: int = posmod(selected_index + direction, buttons.size())
	buttons[next_index].button_pressed = true
	get_viewport().set_input_as_handled()


func _get_level_buttons(button_group: ButtonGroup) -> Array[BaseButton]:
	var buttons: Array[BaseButton] = []
	for child: Node in get_children():
		var button: BaseButton = child as BaseButton
		if button != null and button.button_group == button_group:
			buttons.append(button)
	return buttons
