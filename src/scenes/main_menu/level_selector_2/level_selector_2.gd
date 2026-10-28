@tool
extends TextureButton

@export var level: int = 0
@export_tool_button("Refresh Level Info") var refresh_level_info_action = _load_level_info

const INACTIVE_MODULATE: Color = Color(0.0, 0.0, 0.0, 1.0)
const ACTIVATE_WIDTH: float = 256
const DEFAULT_WIDTH: float = 0
const ANIM_TIME: float = 0.3
const LEVEL_INFO_PATH: String = "res://assets/data/level_info.json"

@onready var texture_rect: TextureRect = $TextureRect
@onready var label_title: Label = $MarginContainer/VBoxContainer/LabelTitle
@onready var label_description: Label = $MarginContainer/VBoxContainer/LabelDescription

var _hover_tween: Tween
var _toggle_tween: Tween

func _ready() -> void:
	toggle_mode = true
	_ensure_button_group()
	if button_group:
		button_group.allow_unpress = false
	_load_level_info()
	
	label_title.text = "Level %s" % (level + 1)
	if button_pressed:
		label_title.visible_ratio = 1.0
		label_description.visible_ratio = 1.0
		texture_rect.modulate = Color.WHITE
	else:
		label_title.visible_ratio = 0.0
		label_description.visible_ratio = 0.0
		texture_rect.modulate = INACTIVE_MODULATE
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	toggled.connect(_on_toggled)


func _ensure_button_group() -> void:
	var parent: Node = get_parent()
	if parent == null:
		return

	var group: ButtonGroup = parent.get_meta("level_selector_button_group", null)
	if group == null:
		for child: Node in parent.get_children():
			if child is TextureButton and child.get_script() == get_script() and child.button_group:
				group = child.button_group
				break
		if group == null:
			group = ButtonGroup.new()
		parent.set_meta("level_selector_button_group", group)

	for child: Node in parent.get_children():
		if child is TextureButton and child.get_script() == get_script():
			child.button_group = group

	button_group = group


func _load_level_info() -> void:
	var info: Dictionary = FileUtils.load_json(LEVEL_INFO_PATH)["levels"][level]
	#label_title.text = info.get("title", "Level %s" % (level + 1))
	label_description.text = info.get("desc", "Lorem Ipsum")

	var texture_path: String = info.get("texture", "")
	if texture_path.is_empty():
		return

	var loaded_texture: Texture2D = load(texture_path)
	if loaded_texture:
		texture_rect.texture = loaded_texture

func _on_toggled(is_active: bool) -> void:
	if _toggle_tween:
		_toggle_tween.kill()
	var target_width: float = ACTIVATE_WIDTH if is_active else DEFAULT_WIDTH
	var target_vis_ratio: float = 1.0 if is_active else 0.0
	_toggle_tween = create_tween()
	_toggle_tween.set_ease(Tween.EASE_IN_OUT)
	_toggle_tween.set_trans(Tween.TRANS_CUBIC)
	_toggle_tween.tween_property(self, "custom_minimum_size:x", target_width, ANIM_TIME)
	_toggle_tween.parallel().tween_property(label_description, "visible_ratio", target_vis_ratio, ANIM_TIME)
	if is_active:
		_set_toggled_visual()
	else:
		_set_untoggled_visual()

func _gui_input(event: InputEvent) -> void:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event == null or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if not button_pressed:
		return
	# Already selected: swallow the click so it can never deselect.
	accept_event()
	if mouse_event.double_click and mouse_event.pressed:
		start_level()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and button_pressed:
		start_level()
		get_viewport().set_input_as_handled()


func start_level() -> void:
	if not button_pressed:
		return
	InterfaceManager.do_on_transition(GameManager.start_game.bind(level))

func _on_mouse_entered() -> void:
	if button_pressed:
		return
	_set_toggled_visual()

func _on_mouse_exited() -> void:
	if button_pressed:
		return
	_set_untoggled_visual()

func _set_toggled_visual() -> void:
	if _hover_tween:
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_CUBIC)
	_hover_tween.set_ease(Tween.EASE_IN_OUT)
	_hover_tween.tween_property(texture_rect, "modulate", Color.WHITE, ANIM_TIME)
	_hover_tween.parallel().tween_property(label_title, "visible_ratio", 1.0, ANIM_TIME)
	texture_rect.process_mode = Node.PROCESS_MODE_INHERIT
	
func _set_untoggled_visual() -> void:
	if _hover_tween:
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_CUBIC)
	_hover_tween.set_ease(Tween.EASE_IN_OUT)
	_hover_tween.tween_property(texture_rect, "modulate", INACTIVE_MODULATE, ANIM_TIME)
	_hover_tween.parallel().tween_property(label_title, "visible_ratio", 0.0, ANIM_TIME)
	texture_rect.process_mode = Node.PROCESS_MODE_DISABLED
