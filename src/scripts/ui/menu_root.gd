extends Control

@export var default_screen : Control

# Flag to prevent visibility changed firing constantly when this hides screens
var displaying_screens: bool = false

func _ready() -> void:
	for control : Control in get_children():
		control.visibility_changed.connect(_on_child_visibility_changed.bind(control))
	_check_show_default()
		
func _on_child_visibility_changed(child : Control):
	if displaying_screens:
		return
	if child.visible:
		display_screen(child)
	else: 
		_check_show_default()
		
func _check_show_default():
	var visible_screens: int = 0
	for control : Control in get_children():
		if control.visible:
			visible_screens += 1
	if visible_screens != 1: # Make it so only one screen can be shown at any time
		display_screen(default_screen)
		
func display_screen(target: Control):
	displaying_screens = true
	for control : Control in get_children():
		control.visible = control == target
	displaying_screens = false
