extends Button

@export var target: Control

func _ready() -> void:
	visibility_changed.connect(_on_vis_changed)
	_on_vis_changed()

func _on_vis_changed():
	set_process_input(is_visible_in_tree())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		_pressed()
		accept_event()

func _pressed() -> void:
	target.hide()
