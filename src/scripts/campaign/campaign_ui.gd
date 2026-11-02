extends CanvasLayer
var result: PanelContainer
var blind: ColorRect
var result_title: Label
var result_stats: Label
var retry: Button
var menu: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	blind = ColorRect.new()
	blind.color = Color(0.035, 0.025, 0.08, 0.76)
	blind.size = Vector2(640, 360)
	blind.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blind.visible = false
	add_child(blind)
	result = _panel(Vector2(70, 65), Vector2(500, 240))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	result.add_child(box)
	result_title = _label("", 30)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(result_title)
	result_stats = _label("", 16)
	result_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(result_stats)
	retry = _button("Try again", box, _restart)
	menu = _button("Back to menu", box, _menu)
	result.hide()
	LevelManager.game_started_event.connect(_start)
	LevelManager.game_ended.connect(_end)

func _style(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("142b2bee")
	style.border_color = Color("d9ae61")
	style.set_border_width_all(2)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)

func _panel(at: Vector2, dimensions: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = at
	panel.size = dimensions
	_style(panel)
	add_child(panel)
	return panel

func _label(message: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = message
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("fff1cf"))
	label.add_theme_color_override("font_outline_color", Color("102321"))
	label.add_theme_constant_override("outline_size", 4)
	return label

func _button(message: String, parent: Node, action: Callable) -> Button:
	var button := Button.new()
	button.text = message
	button.custom_minimum_size.y = 34
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _start() -> void:
	result.hide()

func _process(_delta: float) -> void:
	var level := get_tree().get_first_node_in_group("level_features")
	blind.visible = visible and LevelManager.game_started and is_instance_valid(level) and level.blind_requested

func _end(outcome: int) -> void:
	blind.hide()
	if outcome == LevelManager.GameEnd.OTHER:
		result.hide()
		return
	result.show()
	if outcome == LevelManager.GameEnd.WON:
		result_title.text = "Larga na, Davao!"
		result_stats.text = "Level complete!   %s\nCacao %d/%d  •  Score %d" % ["★".repeat(LevelManager.get_stars()) + "☆".repeat(3 - LevelManager.get_stars()), LevelManager.collected, LevelManager.total_collectibles, LevelManager.score]
	else:
		result_title.text = "Maayo ang pagsulay"
		result_stats.text = "Don't give up."
	retry.visible = outcome == LevelManager.GameEnd.LOST
	menu.grab_focus()

func _restart() -> void:
	InterfaceManager.do_on_transition(LevelManager.restart_level, 0.6)

func _menu() -> void:
	InterfaceManager.do_on_transition(LevelManager.return_to_main_menu, 0.6)
